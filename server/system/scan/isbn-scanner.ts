import type { ISBN } from '~/domain/book/types'
import { createLogger } from '~/system/logger'
import { buildBookJsonSchema, callGemini, normalizeBookFormat } from '~/system/scan/gemini'
import * as repository from '~/system/scan/isbn-repository'
import type { ScanResult } from '~/system/scan/types'

const log = createLogger('isbn-scanner')

const lookupWithGemini = async (isbn: ISBN) => {
  const prompt = `Pour le livre avec l'ISBN ${isbn}, recherche et retourne toutes les informations suivantes au format JSON strict (sans markdown, sans backticks) :

${buildBookJsonSchema(true)}

Recherche les données les plus récentes et précises possibles sur Wikipedia, Goodreads, Babelio, Sens Critique, Amazon et d'autres sources fiables. Toutes les valeurs textuelles en français.`

  const parsed = await callGemini(prompt)

  const title = parsed.title as string | undefined
  const authors = parsed.authors as string[] | undefined
  if (!title || !authors?.length) {
    throw new Error(`Gemini could not find book data for ISBN ${isbn}`)
  }

  return {
    title,
    authors,
    publisher: parsed.publisher as string | undefined,
    publishedDate: parsed.publishedDate as string | undefined,
    pageCount: parsed.pageCount as number | undefined,
    genre: parsed.genre as string | undefined,
    synopsis: parsed.synopsis as string | undefined,
    isbn: (parsed.isbn as string) ?? String(isbn),
    language: parsed.language as string | undefined,
    format: normalizeBookFormat(parsed.format as string | undefined),
    series: parsed.series as string | undefined,
    seriesNumber: parsed.seriesNumber as number | undefined,
    translator: parsed.translator as string | undefined,
    estimatedPrice: parsed.estimatedPrice as number | undefined,
    duration: parsed.duration as string | undefined,
    narrators: (parsed.narrators as string[]) ?? undefined,
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

export namespace IsbnScanner {
  export const scan = async (isbn: ISBN) => {
    const cached = await repository.findBy(isbn)
    if (cached) {
      log.info('Cache hit for ISBN', String(isbn))
      return cached.result
    }

    log.info('Looking up ISBN with Gemini...', String(isbn))
    const result = await lookupWithGemini(isbn)

    await repository.save({
      isbn,
      result,
      cachedAt: new Date(),
    })

    return result
  }
}
