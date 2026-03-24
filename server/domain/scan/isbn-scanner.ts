import type { ISBN } from '~/domain/book/types'
import { buildBookJsonSchema, callGemini, normalizeBookFormat } from '~/domain/scan/gemini'
import * as repository from '~/domain/scan/isbn-repository'
import { enrichWithHardcover, type HardcoverEnrichment } from '~/domain/scan/scanner'
import { scanResultSchema } from '~/domain/scan/schemas'
import type { ScanResult } from '~/domain/scan/types'
import { createLogger } from '~/system/logger'

const log = createLogger('isbn-scanner')

const lookupWithGemini = async (isbn: ISBN, existingSeriesNames: string[] = []) => {
  const prompt = `Pour le livre avec l'ISBN ${isbn}, recherche et retourne toutes les informations suivantes au format JSON strict (sans markdown, sans backticks) :

${buildBookJsonSchema(true, existingSeriesNames)}

Recherche les données les plus récentes et précises possibles sur Wikipedia, Goodreads, Babelio, Sens Critique, Amazon et d'autres sources fiables. Toutes les valeurs textuelles en français.`

  const raw = await callGemini(prompt)
  const parsed = scanResultSchema.parse(raw)
  return {
    ...parsed,
    isbn: parsed.isbn ?? String(isbn),
    format: normalizeBookFormat(parsed.format),
  }
}

export type IsbnScanOutput = {
  result: ScanResult
  coverImageBase64?: string
}

export namespace IsbnScanner {
  export const scan = async (
    isbn: ISBN,
    existingSeriesNames: string[] = [],
  ): Promise<IsbnScanOutput> => {
    const cached = await repository.findBy(isbn)
    if (cached) {
      log.info('Cache hit for ISBN', String(isbn))
      const hardcover = await enrichWithHardcover(cached.result)
      return { result: cached.result, coverImageBase64: hardcover.coverImageBase64 }
    }

    log.info('Looking up ISBN with Gemini + Hardcover...', String(isbn))
    const geminiResult = await lookupWithGemini(isbn, existingSeriesNames)

    const hardcover = await enrichWithHardcover(geminiResult)
    const result = mergeIsbnEnrichments(hardcover, geminiResult)

    await repository.save({
      isbn,
      result,
      cachedAt: new Date(),
    })

    return { result, coverImageBase64: hardcover.coverImageBase64 }
  }
}

const mergeIsbnEnrichments = (hardcover: HardcoverEnrichment, geminiResult: ScanResult) => ({
  ...geminiResult,
  publicRatings: hardcover.result.publicRatings,
  genre: geminiResult.genre ?? hardcover.result.genre,
  pageCount: geminiResult.pageCount ?? hardcover.result.pageCount,
})
