import { createHash } from 'node:crypto'
import type { BookFormat } from '~/domain/book/types'
import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'
import { ImageHash } from '~/system/scan/primitives'
import * as repository from '~/system/scan/repository'
import type { ScanResult } from '~/system/scan/types'

const log = createLogger('scan')

const formatAliases: Record<string, BookFormat> = {
  pocket: 'pocket',
  poche: 'pocket',
  'format poche': 'pocket',
  'livre de poche': 'pocket',
  'mass market': 'pocket',
  'mass market paperback': 'pocket',
  paperback: 'paperback',
  broché: 'paperback',
  'grand format': 'paperback',
  'trade paperback': 'paperback',
  hardcover: 'hardcover',
  relié: 'hardcover',
  cartonné: 'hardcover',
  'couverture rigide': 'hardcover',
  audiobook: 'audiobook',
  'livre audio': 'audiobook',
  audio: 'audiobook',
}

const normalizeBookFormat = (value: string | undefined): BookFormat | undefined => {
  if (!value) return undefined
  const normalized = formatAliases[value.toLowerCase().trim()]
  if (!normalized) log.warn('Unknown book format, discarding', value)
  return normalized
}

const ANTHROPIC_API_URL = 'https://api.anthropic.com/v1/messages'
const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'

const hashImage = (buffer: Buffer) => {
  const hash = createHash('sha256').update(buffer).digest('hex')
  return ImageHash(hash)
}

const extractBookInfoTool = {
  name: 'extract_book_info',
  description: 'Extract book information from a cover image',
  input_schema: {
    type: 'object' as const,
    properties: {
      title: { type: 'string', description: 'Book title' },
      authors: {
        type: 'array',
        items: { type: 'string' },
        description: 'List of authors',
      },
      publisher: { type: 'string', description: 'Publisher name' },
      publishedDate: { type: 'string', description: 'Publication date' },
      pageCount: { type: 'number', description: 'Number of pages' },
      genre: { type: 'string', description: 'Book genre' },
      synopsis: { type: 'string', description: 'Book synopsis in French' },
      isbn: { type: 'string', description: 'ISBN number' },
      language: { type: 'string', description: 'Book language' },
      format: { type: 'string', description: 'Book format (pocket, paperback, hardcover)' },
      series: { type: 'string', description: 'Series name if part of a series' },
      seriesNumber: { type: 'number', description: 'Position in the series' },
      translator: { type: 'string', description: 'Translator name' },
      estimatedPrice: { type: 'number', description: 'Estimated price in euros' },
    },
    required: ['title', 'authors'],
  },
}

const scanWithClaude = async (imageBase64: string) => {
  const { anthropicApiKey } = config()

  const response = await $fetch<{
    content: Array<{ type: string; name?: string; input?: Record<string, unknown> }>
  }>(ANTHROPIC_API_URL, {
    method: 'POST',
    headers: {
      'x-api-key': String(anthropicApiKey),
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: {
      model: 'claude-sonnet-4-5-20250929',
      max_tokens: 1024,
      tools: [extractBookInfoTool],
      tool_choice: { type: 'tool', name: 'extract_book_info' },
      messages: [
        {
          role: 'user',
          content: [
            {
              type: 'image',
              source: {
                type: 'base64',
                media_type: 'image/jpeg',
                data: imageBase64,
              },
            },
            {
              type: 'text',
              text: "Analyse cette couverture de livre et extrais toutes les informations visibles. Toutes les valeurs textuelles doivent être en français. Utilise l'outil extract_book_info pour retourner les données.",
            },
          ],
        },
      ],
    },
  })

  const toolUse = response.content.find(
    (block) => block.type === 'tool_use' && block.name === 'extract_book_info',
  )

  if (!toolUse?.input) {
    throw new Error('Claude did not return tool_use result')
  }

  const input = toolUse.input
  return {
    title: input.title as string,
    authors: (input.authors as string[]) ?? [],
    publisher: input.publisher as string | undefined,
    publishedDate: input.publishedDate as string | undefined,
    pageCount: input.pageCount as number | undefined,
    genre: input.genre as string | undefined,
    synopsis: input.synopsis as string | undefined,
    isbn: input.isbn as string | undefined,
    language: input.language as string | undefined,
    format: normalizeBookFormat(input.format as string | undefined),
    series: input.series as string | undefined,
    seriesNumber: input.seriesNumber as number | undefined,
    translator: input.translator as string | undefined,
    estimatedPrice: input.estimatedPrice as number | undefined,
    awards: [] as { name: string; year?: number }[],
    publicRatings: [] as { source: string; score: number; maxScore: number; voterCount: number }[],
  } satisfies ScanResult
}

type OpenLibraryData = {
  publisher?: string
  pageCount?: number
  publishedDate?: string
  synopsis?: string
}

const lookupByIsbn = async (isbn: string | undefined): Promise<OpenLibraryData | undefined> => {
  if (!isbn) return undefined
  const cleanIsbn = isbn.replace(/[-\s]/g, '')

  try {
    log.info('Looking up ISBN on Open Library...', cleanIsbn)
    const edition = await $fetch<Record<string, unknown>>(
      `https://openlibrary.org/isbn/${cleanIsbn}.json`,
    )

    let synopsis: string | undefined
    const works = edition.works as { key: string }[] | undefined
    if (works?.[0]?.key) {
      try {
        const work = await $fetch<Record<string, unknown>>(
          `https://openlibrary.org${works[0].key}.json`,
        )
        const desc = work.description
        synopsis = typeof desc === 'string' ? desc : (desc as { value?: string })?.value
      } catch {
        /* best-effort */
      }
    }

    const publishers = edition.publishers as string[] | undefined
    return {
      publisher: publishers?.[0],
      pageCount: edition.number_of_pages as number | undefined,
      publishedDate: edition.publish_date as string | undefined,
      synopsis,
    }
  } catch {
    log.info('Open Library lookup failed, skipping')
    return undefined
  }
}

const enrichWithGemini = async (scanResult: ScanResult) => {
  const { googleApiKey } = config()

  const bookDescription = [
    scanResult.title,
    scanResult.authors.join(', '),
    scanResult.isbn ? `ISBN: ${scanResult.isbn}` : undefined,
  ]
    .filter(Boolean)
    .join(' - ')

  const prompt = `Pour le livre "${bookDescription}", recherche et complète les informations suivantes au format JSON strict (sans markdown, sans backticks) :

{
  "estimatedPrice": number ou null (prix moyen en euros sur les librairies françaises),
  "pageCount": number ou null,
  "synopsis": string ou null (résumé de 3-5 phrases en français, pas la 4ème de couverture mais un vrai résumé du contenu),
  "isbn": string ou null (ISBN-13 de préférence),
  "language": string ou null (langue originale du texte),
  "genre": string ou null (sous-genres séparés par des virgules, ex: "LitRPG, Science Fantasy" ou "Thriller, Policier" — sois précis et spécifique),
  "series": string ou null (nom de la série ou du cycle),
  "seriesNumber": number ou null (numéro du tome dans la série),
  "publisher": string ou null (maison d'édition de cette édition),
  "publishedDate": string ou null (date de première publication, format YYYY-MM-DD ou YYYY),
  "format": string ou null ("pocket", "paperback" ou "hardcover"),
  "translator": string ou null (traducteur si c'est une traduction),
  "awards": [{"name": string, "year": number}] (tous les prix littéraires reçus, tableau vide si aucun — cherche sur Wikipedia et les sites de prix),
  "publicRatings": [{"source": "Babelio", "score": number, "maxScore": number, "voterCount": number}, {"source": "Goodreads", "score": number, "maxScore": number, "voterCount": number}] (notes sur Babelio sur 5 et Goodreads sur 5, avec le nombre de votants — cherche les notes actuelles)
}

Recherche les données les plus récentes et précises possibles. Toutes les valeurs textuelles en français.`

  try {
    const response = await $fetch<{
      candidates: { content: { parts: { text?: string }[] } }[]
    }>(`${GEMINI_API_URL}?key=${googleApiKey}`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: {
        contents: [{ parts: [{ text: prompt }] }],
        tools: [{ google_search: {} }],
      },
    })

    const text = response.candidates?.[0]?.content?.parts?.find((part) => part.text)?.text
    if (!text) return scanResult

    const jsonMatch = text.match(/\{[\s\S]*\}/)
    if (!jsonMatch) return scanResult

    const enriched = JSON.parse(jsonMatch[0]) as Record<string, unknown>

    return {
      title: scanResult.title,
      authors: scanResult.authors,
      publisher: (enriched.publisher as string) ?? scanResult.publisher,
      publishedDate: (enriched.publishedDate as string) ?? scanResult.publishedDate,
      pageCount: (enriched.pageCount as number) ?? scanResult.pageCount,
      genre: (enriched.genre as string) ?? scanResult.genre,
      synopsis: (enriched.synopsis as string) ?? scanResult.synopsis,
      isbn: (enriched.isbn as string) ?? scanResult.isbn,
      language: (enriched.language as string) ?? scanResult.language,
      format: normalizeBookFormat(enriched.format as string) ?? scanResult.format,
      series: (enriched.series as string) ?? scanResult.series,
      seriesNumber: (enriched.seriesNumber as number) ?? scanResult.seriesNumber,
      translator: (enriched.translator as string) ?? scanResult.translator,
      estimatedPrice: (enriched.estimatedPrice as number) ?? scanResult.estimatedPrice,
      awards: (enriched.awards as { name: string; year?: number }[]) ?? scanResult.awards,
      publicRatings:
        (enriched.publicRatings as {
          source: string
          score: number
          maxScore: number
          voterCount: number
        }[]) ?? scanResult.publicRatings,
    } satisfies ScanResult
  } catch (error) {
    log.error('Gemini enrichment failed, using scan result only', error)
    return scanResult
  }
}

export namespace BookScanner {
  export const scan = async (imageBuffer: Buffer) => {
    const imageHash = hashImage(imageBuffer)

    const cached = await repository.findBy(imageHash)
    if (cached) {
      log.info('Cache hit for image', imageHash)
      return cached.result
    }

    const imageBase64 = imageBuffer.toString('base64')

    log.info('Scanning book cover with Claude Vision...')
    const scanResult = await scanWithClaude(imageBase64)

    const isbnData = await lookupByIsbn(scanResult.isbn)
    const withIsbn: ScanResult = isbnData
      ? {
          ...scanResult,
          publisher: isbnData.publisher ?? scanResult.publisher,
          pageCount: isbnData.pageCount ?? scanResult.pageCount,
          publishedDate: isbnData.publishedDate ?? scanResult.publishedDate,
          synopsis: scanResult.synopsis ?? isbnData.synopsis,
        }
      : scanResult

    log.info('Enriching with Gemini...', withIsbn.title)
    const enrichedResult = await enrichWithGemini(withIsbn)

    await repository.save({
      imageHash,
      result: enrichedResult,
      cachedAt: new Date(),
    })

    return enrichedResult
  }
}
