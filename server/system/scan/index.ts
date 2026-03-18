import { createHash } from 'node:crypto'
import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'
import { buildBookJsonSchema, callGemini, normalizeBookFormat } from '~/system/scan/gemini'
import { ImageHash } from '~/system/scan/primitives'
import * as repository from '~/system/scan/repository'
import type { ScanResult } from '~/system/scan/types'

const log = createLogger('scan')

const ANTHROPIC_API_URL = 'https://api.anthropic.com/v1/messages'

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
              text: 'Analyse cette couverture de livre et extrais toutes les informations visibles. Le titre doit être uniquement le titre du livre, sans préfixe de série ni numéro de tome (ex: "Le Nom du Vent" et non "Les Chroniques du Tueur de Roi, Tome 1 : Le Nom du Vent"). Si le livre fait partie d\'une série, utilise les champs series et seriesNumber. Toutes les valeurs textuelles doivent être en français. Utilise l\'outil extract_book_info pour retourner les données.',
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

export type OpenLibraryData = {
  publisher?: string
  pageCount?: number
  publishedDate?: string
  synopsis?: string
}

export const lookupByIsbn = async (
  isbn: string | undefined,
): Promise<OpenLibraryData | undefined> => {
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
  const bookDescription = [
    scanResult.title,
    scanResult.authors.join(', '),
    scanResult.isbn ? `ISBN: ${scanResult.isbn}` : undefined,
  ]
    .filter(Boolean)
    .join(' - ')

  const prompt = `Pour le livre "${bookDescription}", recherche et complète les informations suivantes au format JSON strict (sans markdown, sans backticks) :

${buildBookJsonSchema(false)}

Recherche les données les plus récentes et précises possibles. Toutes les valeurs textuelles en français.`

  try {
    const enriched = await callGemini(prompt)

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
      duration: (enriched.duration as string) ?? scanResult.duration,
      narrators: (enriched.narrators as string[]) ?? scanResult.narrators,
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
