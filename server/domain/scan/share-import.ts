import { createHash } from 'node:crypto'
import {
  buildBookJsonSchema,
  callGemini,
  normalizeBookFormat,
} from '~/domain/scan/infrastructure/gemini'
import * as repository from '~/domain/scan/infrastructure/url-import-repository'
import { UrlHash } from '~/domain/scan/primitives'
import { scanResultSchema } from '~/domain/scan/schemas'
import type { ScanResult } from '~/domain/scan/types'
import { createLogger } from '~/system/logger'

const log = createLogger('share-import')

const hashUrl = (url: string) => {
  const hash = createHash('sha256').update(url).digest('hex')
  return UrlHash(hash)
}

export type ShareData = {
  url: string
  description?: string
  rawText?: string
  attachmentTypes?: string[]
  metaTags?: Record<string, string>
}

const META_TAG_PATTERNS = [
  // Open Graph
  /<meta\s+(?:property|name)=["']og:([^"']+)["']\s+content=["']([^"']*)["']/gi,
  /<meta\s+content=["']([^"']*)["']\s+(?:property|name)=["']og:([^"']+)["']/gi,
  // Standard meta
  /<meta\s+name=["'](description|author|keywords)["']\s+content=["']([^"']*)["']/gi,
  /<meta\s+content=["']([^"']*)["']\s+name=["'](description|author|keywords)["']/gi,
  // Schema.org book/music
  /<meta\s+(?:property|name)=["']((?:book|music):[^"']+)["']\s+content=["']([^"']*)["']/gi,
  /<meta\s+content=["']([^"']*)["']\s+(?:property|name)=["']((?:book|music):[^"']+)["']/gi,
]

const fetchMetaTags = async (url: string): Promise<Record<string, string>> => {
  try {
    const html = await $fetch<string>(url, {
      responseType: 'text',
      timeout: 5000,
      headers: { 'user-agent': 'Mozilla/5.0 (compatible; Pchook/1.0)' },
    })

    const tags: Record<string, string> = {}

    const titleMatch = html.match(/<title[^>]*>([^<]+)<\/title>/i)
    if (titleMatch) tags.title = titleMatch[1].trim()

    for (const pattern of META_TAG_PATTERNS) {
      const isReversed = pattern.source.startsWith('<meta\\s+content')
      for (const match of html.matchAll(pattern)) {
        const [, first, second] = match
        const key = isReversed ? second : first
        const value = isReversed ? first : second
        if (value) tags[key] = value.trim()
      }
    }

    log.info('Meta tags fetched', { url, tags })
    return tags
  } catch (error) {
    log.warn('Failed to fetch meta tags', { url, error: String(error) })
    return {}
  }
}

const buildSourceBlock = ({ url, description, rawText, metaTags }: ShareData) => {
  const parts: string[] = []

  if (description) {
    parts.push(`Description partagée (source principale) :\n${description}`)
  }

  if (rawText && rawText !== description) {
    parts.push(`Texte brut additionnel :\n${rawText}`)
  }

  if (metaTags && Object.keys(metaTags).length > 0) {
    const tagLines = Object.entries(metaTags)
      .map(([key, value]) => `${key}: "${value}"`)
      .join('\n')
    parts.push(`Meta tags de la page :\n${tagLines}`)
  }

  parts.push(`URL de référence${description ? ' (source secondaire)' : ''} : ${url}`)

  if (parts.length > 1) {
    return `Analyse ces informations sur un livre :\n\n${parts.join('\n\n')}\n\nIdentifie le livre référencé et retourne toutes les informations au format JSON strict (sans markdown, sans backticks).\nSi la description et l'URL fournissent des informations contradictoires, privilégie la description.`
  }

  return `Visite et analyse cette URL : ${url}\n\nIdentifie le livre référencé et retourne toutes les informations au format JSON strict (sans markdown, sans backticks) :`
}

const extractFromShare = async (data: ShareData, existingSeriesNames: string[] = []) => {
  log.info('Share data received', {
    url: data.url,
    description: data.description,
    rawText: data.rawText,
    attachmentTypes: data.attachmentTypes,
  })

  const sourceBlock = buildSourceBlock(data)

  const prompt = `${sourceBlock}

${buildBookJsonSchema(true, existingSeriesNames)}

Si l'URL est un lien Audible/Amazon, le format est probablement "audiobook".
Recherche les données les plus récentes et précises possibles. Toutes les valeurs textuelles en français.`

  const raw = await callGemini(prompt)
  const parsed = scanResultSchema.parse(raw)

  log.info('Gemini parsed result', {
    title: parsed.title,
    authors: parsed.authors,
    isbn: parsed.isbn,
    format: parsed.format,
  })

  return { ...parsed, format: normalizeBookFormat(parsed.format) }
}

export namespace ShareImporter {
  export const importFromShare = async (
    data: ShareData,
    existingSeriesNames: string[] = [],
  ): Promise<ScanResult | 'extraction-failed'> => {
    const urlHash = hashUrl(data.url)

    const cached = await repository.findBy(urlHash)
    if (cached) {
      log.info('Cache hit for URL', urlHash)
      return cached.result
    }

    const metaTags = await fetchMetaTags(data.url)
    const enrichedData: ShareData = { ...data, metaTags }

    const hasContext = !!data.description || !!data.rawText || Object.keys(metaTags).length > 0

    if (!hasContext) {
      log.warn('No context available for extraction, URL only', data.url)
    }

    let extracted: ScanResult
    try {
      extracted = await extractFromShare(enrichedData, existingSeriesNames)
    } catch (error) {
      log.error('Extraction failed', { url: data.url, error: String(error) })
      return 'extraction-failed' as const
    }

    const scanResult = extracted

    await repository.save({
      urlHash,
      result: scanResult,
      cachedAt: new Date(),
    })

    return scanResult
  }
}
