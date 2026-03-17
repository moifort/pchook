import { createHash } from 'node:crypto'
import type { BookFormat } from '~/domain/book/types'
import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'
import { lookupByIsbn } from '~/system/scan/index'
import { UrlHash } from '~/system/scan/primitives'
import type { ScanResult } from '~/system/scan/types'
import * as repository from '~/system/scan/url-import-repository'

const log = createLogger('share-import')

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

export type ShareData = {
  url: string
  description?: string
  rawText?: string
  attachmentTypes?: string[]
}

const buildSourceBlock = ({ url, description, rawText }: ShareData) => {
  const parts: string[] = []

  if (description) {
    parts.push(`Description partagée (source principale) :\n${description}`)
  }

  if (rawText && rawText !== description) {
    parts.push(`Texte brut additionnel :\n${rawText}`)
  }

  parts.push(`URL de référence${description ? ' (source secondaire)' : ''} : ${url}`)

  if (parts.length > 1) {
    return `Analyse ces informations sur un livre :\n\n${parts.join('\n\n')}\n\nIdentifie le livre référencé et retourne toutes les informations au format JSON strict (sans markdown, sans backticks).\nSi la description et l'URL fournissent des informations contradictoires, privilégie la description.`
  }

  return `Visite et analyse cette URL : ${url}\n\nIdentifie le livre référencé et retourne toutes les informations au format JSON strict (sans markdown, sans backticks) :`
}

const extractFromShare = async (data: ShareData) => {
  const { googleApiKey } = config()

  log.info('Share data received', {
    url: data.url,
    description: data.description,
    rawText: data.rawText,
    attachmentTypes: data.attachmentTypes,
  })

  const sourceBlock = buildSourceBlock(data)

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
  "publicRatings": [{"source": string, "score": number, "maxScore": number, "voterCount": number}] (cherche les notes actuelles sur toutes les plateformes pertinentes : Goodreads /5, Babelio /5, Sens Critique /10, Amazon /5, etc. — inclus chaque source trouvée avec son score, son barème et le nombre de votants)
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

  log.info('Gemini raw response', text)

  const jsonMatch = text.match(/\{[\s\S]*\}/)
  if (!jsonMatch) throw new Error('Gemini did not return valid JSON')

  const parsed = JSON.parse(jsonMatch[0]) as Record<string, unknown>

  const title = parsed.title as string | undefined
  const authors = parsed.authors as string[] | undefined
  if (!title || !authors?.length)
    throw new Error('Gemini could not identify the book from share data')

  log.info('Gemini parsed result', {
    title,
    authors,
    isbn: parsed.isbn,
    format: parsed.format,
  })

  return {
    title,
    authors,
    publisher: parsed.publisher as string | undefined,
    publishedDate: parsed.publishedDate as string | undefined,
    pageCount: parsed.pageCount as number | undefined,
    genre: parsed.genre as string | undefined,
    synopsis: parsed.synopsis as string | undefined,
    isbn: parsed.isbn as string | undefined,
    language: parsed.language as string | undefined,
    format: normalizeBookFormat(parsed.format as string | undefined),
    series: parsed.series as string | undefined,
    seriesNumber: parsed.seriesNumber as number | undefined,
    translator: parsed.translator as string | undefined,
    estimatedPrice: parsed.estimatedPrice as number | undefined,
    awards: (parsed.awards as { name: string; year?: number }[]) ?? [],
    publicRatings:
      (parsed.publicRatings as {
        source: string
        score: number
        maxScore: number
        voterCount: number
      }[]) ?? [],
  } satisfies ScanResult
}

export namespace ShareImporter {
  export const importFromShare = async (data: ShareData) => {
    const urlHash = hashUrl(data.url)

    const cached = await repository.findBy(urlHash)
    if (cached) {
      log.info('Cache hit for URL', urlHash)
      return cached.result
    }

    const extracted = await extractFromShare(data)

    const isbnData = await lookupByIsbn(extracted.isbn)
    log.info('ISBN lookup result', isbnData ?? 'no data')

    const scanResult: ScanResult = isbnData
      ? {
          ...extracted,
          publisher: isbnData.publisher ?? extracted.publisher,
          pageCount: isbnData.pageCount ?? extracted.pageCount,
          publishedDate: isbnData.publishedDate ?? extracted.publishedDate,
          synopsis: extracted.synopsis ?? isbnData.synopsis,
        }
      : extracted

    await repository.save({
      urlHash,
      result: scanResult,
      cachedAt: new Date(),
    })

    return scanResult
  }
}
