import { createHash } from 'node:crypto'
import type { BookFormat } from '~/domain/book/types'
import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'
import { lookupByIsbn } from '~/system/scan/index'
import { UrlHash } from '~/system/scan/primitives'
import type { ScanResult } from '~/system/scan/types'
import * as repository from '~/system/scan/url-import-repository'

const log = createLogger('url-import')

const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'

const formatAliases: Record<string, BookFormat> = {
  pocket: 'pocket',
  poche: 'pocket',
  'format poche': 'pocket',
  'livre de poche': 'pocket',
  paperback: 'paperback',
  broché: 'paperback',
  'grand format': 'paperback',
  hardcover: 'hardcover',
  relié: 'hardcover',
  cartonné: 'hardcover',
  audiobook: 'audiobook',
  'livre audio': 'audiobook',
  audio: 'audiobook',
}

const normalizeBookFormat = (value: string | undefined): BookFormat | undefined => {
  if (!value) return undefined
  return formatAliases[value.toLowerCase().trim()]
}

const hashUrl = (url: string) => {
  const hash = createHash('sha256').update(url).digest('hex')
  return UrlHash(hash)
}

const extractFromUrl = async (url: string, description?: string) => {
  const { googleApiKey } = config()

  const sourceBlock = description
    ? `Analyse ces informations sur un livre :

Description partagée (source principale) :
${description}

URL de référence (source secondaire) : ${url}

Identifie le livre référencé et retourne toutes les informations au format JSON strict (sans markdown, sans backticks).
Si la description et l'URL fournissent des informations contradictoires, privilégie la description.`
    : `Visite et analyse cette URL : ${url}

Identifie le livre référencé et retourne toutes les informations au format JSON strict (sans markdown, sans backticks) :`

  const prompt = `${sourceBlock}

{
  "title": string (titre du livre uniquement, sans préfixe de série ni numéro de tome — ex: "Le Nom du Vent" et non "Tome 1 : Le Nom du Vent"),
  "authors": string[] (liste des auteurs),
  "publisher": string ou null (maison d'édition),
  "publishedDate": string ou null (date de première publication, format YYYY-MM-DD ou YYYY),
  "pageCount": number ou null,
  "genre": string ou null (sous-genres séparés par des virgules, ex: "LitRPG, Science Fantasy" ou "Thriller, Policier" — sois précis et spécifique),
  "synopsis": string ou null (résumé de 3-5 phrases en français, pas la 4ème de couverture mais un vrai résumé du contenu),
  "isbn": string ou null (ISBN-13 de préférence),
  "language": string ou null (langue originale du texte),
  "format": string ou null ("pocket", "paperback", "hardcover" ou "audiobook"),
  "series": string ou null (nom de la série ou du cycle),
  "seriesNumber": number ou null (numéro du tome dans la série),
  "translator": string ou null (traducteur si c'est une traduction),
  "estimatedPrice": number ou null (prix moyen en euros sur les librairies françaises),
  "awards": [{"name": string, "year": number}] (tous les prix littéraires reçus, tableau vide si aucun — cherche sur Wikipedia et les sites de prix),
  "publicRatings": [{"source": string, "score": number, "maxScore": number, "voterCount": number}] (cherche les notes actuelles sur toutes les plateformes pertinentes : Goodreads /5, Babelio /5, Sens Critique /10, Amazon /5, etc. — inclus chaque source trouvée avec son score, son barème et le nombre de votants),
  "coverImageUrl": string ou null (URL de l'image de couverture du livre, haute résolution de préférence)
}

Si l'URL est un lien Audible/Amazon, le format est probablement "audiobook".
Recherche les données les plus récentes et précises possibles. Toutes les valeurs textuelles en français.`

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
  if (!text) throw new Error('Gemini did not return any text')

  const jsonMatch = text.match(/\{[\s\S]*\}/)
  if (!jsonMatch) throw new Error('Gemini did not return valid JSON')

  const data = JSON.parse(jsonMatch[0]) as Record<string, unknown>

  const title = data.title as string | undefined
  const authors = data.authors as string[] | undefined
  if (!title || !authors?.length) throw new Error('Gemini could not identify the book from URL')

  return {
    scanResult: {
      title,
      authors,
      publisher: data.publisher as string | undefined,
      publishedDate: data.publishedDate as string | undefined,
      pageCount: data.pageCount as number | undefined,
      genre: data.genre as string | undefined,
      synopsis: data.synopsis as string | undefined,
      isbn: data.isbn as string | undefined,
      language: data.language as string | undefined,
      format: normalizeBookFormat(data.format as string | undefined),
      series: data.series as string | undefined,
      seriesNumber: data.seriesNumber as number | undefined,
      translator: data.translator as string | undefined,
      estimatedPrice: data.estimatedPrice as number | undefined,
      awards: (data.awards as { name: string; year?: number }[]) ?? [],
      publicRatings:
        (data.publicRatings as {
          source: string
          score: number
          maxScore: number
          voterCount: number
        }[]) ?? [],
    } satisfies ScanResult,
    coverImageUrl: data.coverImageUrl as string | undefined,
  }
}

const fetchCoverImage = async (coverImageUrl: string | undefined) => {
  if (!coverImageUrl) return undefined

  try {
    log.info('Fetching cover image...', coverImageUrl)
    const response = await $fetch<ArrayBuffer>(coverImageUrl, { responseType: 'arrayBuffer' })
    return Buffer.from(response).toString('base64')
  } catch (error) {
    log.warn('Failed to fetch cover image, skipping', error)
    return undefined
  }
}

export namespace UrlImporter {
  export const importFromUrl = async (url: string, description?: string) => {
    const urlHash = hashUrl(url)

    const cached = await repository.findBy(urlHash)
    if (cached) {
      log.info('Cache hit for URL', urlHash)
      return { scanResult: cached.result, coverImageBase64: undefined }
    }

    log.info('Extracting book info from URL...', url)
    const { scanResult: extracted, coverImageUrl } = await extractFromUrl(url, description)

    const isbnData = await lookupByIsbn(extracted.isbn)
    const withIsbn: ScanResult = isbnData
      ? {
          ...extracted,
          publisher: isbnData.publisher ?? extracted.publisher,
          pageCount: isbnData.pageCount ?? extracted.pageCount,
          publishedDate: isbnData.publishedDate ?? extracted.publishedDate,
          synopsis: extracted.synopsis ?? isbnData.synopsis,
        }
      : extracted

    const coverImageBase64 = await fetchCoverImage(coverImageUrl)

    await repository.save({
      urlHash,
      result: withIsbn,
      cachedAt: new Date(),
    })

    return { scanResult: withIsbn, coverImageBase64 }
  }
}
