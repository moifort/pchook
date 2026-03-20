import { createHash } from 'node:crypto'
import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'
import { buildBookJsonSchema, callGemini, normalizeBookFormat } from '~/system/scan/gemini'
import { ImageHash } from '~/system/scan/primitives'
import * as repository from '~/system/scan/repository'
import { partialScanResultSchema, scanResultSchema } from '~/system/scan/schemas'
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

  const parsed = scanResultSchema.parse(toolUse.input)
  return { ...parsed, format: normalizeBookFormat(parsed.format) }
}

const scanWithNativeOcr = async (ocrText: string, existingSeriesNames: string[] = []) => {
  const prompt = `Pour le livre dont voici le texte extrait de la couverture par OCR :

"${ocrText}"

Identifie ce livre et retourne toutes les informations suivantes au format JSON strict (sans markdown, sans backticks) :

${buildBookJsonSchema(true, existingSeriesNames)}

Recherche les données les plus récentes et précises possibles sur Wikipedia, Goodreads, Babelio, Sens Critique, Amazon et d'autres sources fiables. Toutes les valeurs textuelles en français.`

  const raw = await callGemini(prompt)
  const parsed = scanResultSchema.parse(raw)
  return { ...parsed, format: normalizeBookFormat(parsed.format) }
}

export const enrichWithGemini = async (
  scanResult: ScanResult,
  existingSeriesNames: string[] = [],
) => {
  const bookDescription = [
    scanResult.title,
    scanResult.authors.join(', '),
    scanResult.isbn ? `ISBN: ${scanResult.isbn}` : undefined,
  ]
    .filter(Boolean)
    .join(' - ')

  const prompt = `Pour le livre "${bookDescription}", recherche et complète les informations suivantes au format JSON strict (sans markdown, sans backticks) :

${buildBookJsonSchema(false, existingSeriesNames)}

Recherche les données les plus récentes et précises possibles. Toutes les valeurs textuelles en français.`

  try {
    const raw = await callGemini(prompt)
    const enriched = partialScanResultSchema.parse(raw)

    return {
      ...scanResult,
      publisher: enriched.publisher ?? scanResult.publisher,
      publishedDate: enriched.publishedDate ?? scanResult.publishedDate,
      pageCount: enriched.pageCount ?? scanResult.pageCount,
      genre: enriched.genre ?? scanResult.genre,
      synopsis: enriched.synopsis ?? scanResult.synopsis,
      isbn: enriched.isbn ?? scanResult.isbn,
      language: enriched.language ?? scanResult.language,
      format: normalizeBookFormat(enriched.format) ?? scanResult.format,
      series: enriched.series ?? scanResult.series,
      seriesLabel: enriched.seriesLabel ?? scanResult.seriesLabel,
      seriesNumber: enriched.seriesNumber ?? scanResult.seriesNumber,
      translator: enriched.translator ?? scanResult.translator,
      estimatedPrice: enriched.estimatedPrice ?? scanResult.estimatedPrice,
      duration: enriched.duration ?? scanResult.duration,
      narrators: enriched.narrators ?? scanResult.narrators,
      awards: enriched.awards.length > 0 ? enriched.awards : scanResult.awards,
      publicRatings:
        enriched.publicRatings.length > 0 ? enriched.publicRatings : scanResult.publicRatings,
    } satisfies ScanResult
  } catch (error) {
    log.error('Gemini enrichment failed, using scan result only', error)
    return scanResult
  }
}

export namespace BookScanner {
  export const scan = async (
    imageBuffer: Buffer,
    ocrText?: string,
    existingSeriesNames: string[] = [],
  ) => {
    const imageHash = hashImage(imageBuffer)

    const cached = await repository.findBy(imageHash)
    if (cached) {
      log.info('Cache hit for image', imageHash)
      return cached.result
    }

    const { scanStrategy } = config()

    const scanResult =
      scanStrategy === 'native'
        ? await scanWithNativeOcrStrategy(ocrText, existingSeriesNames)
        : await scanWithClaudeStrategy(imageBuffer, existingSeriesNames)

    await repository.save({
      imageHash,
      result: scanResult,
      cachedAt: new Date(),
    })

    return scanResult
  }
}

const scanWithClaudeStrategy = async (imageBuffer: Buffer, existingSeriesNames: string[] = []) => {
  const imageBase64 = imageBuffer.toString('base64')

  log.info('Scanning book cover with Claude Vision...')
  const scanResult = await scanWithClaude(imageBase64)

  log.info('Enriching with Gemini...', scanResult.title)
  return await enrichWithGemini(scanResult, existingSeriesNames)
}

const scanWithNativeOcrStrategy = async (
  ocrText: string | undefined,
  existingSeriesNames: string[] = [],
) => {
  if (!ocrText?.trim()) {
    throw createError({
      statusCode: 422,
      statusMessage: 'OCR text is empty — cannot identify book',
    })
  }

  log.info('Scanning book cover with native OCR text...')
  return await scanWithNativeOcr(ocrText.trim(), existingSeriesNames)
}
