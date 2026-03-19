import type { ISBN } from '~/domain/book/types'
import { createLogger } from '~/system/logger'
import { buildBookJsonSchema, callGemini, normalizeBookFormat } from '~/system/scan/gemini'
import * as repository from '~/system/scan/isbn-repository'
import { scanResultSchema } from '~/system/scan/schemas'

const log = createLogger('isbn-scanner')

const lookupWithGemini = async (isbn: ISBN) => {
  const prompt = `Pour le livre avec l'ISBN ${isbn}, recherche et retourne toutes les informations suivantes au format JSON strict (sans markdown, sans backticks) :

${buildBookJsonSchema(true)}

Recherche les données les plus récentes et précises possibles sur Wikipedia, Goodreads, Babelio, Sens Critique, Amazon et d'autres sources fiables. Toutes les valeurs textuelles en français.`

  const raw = await callGemini(prompt)
  const parsed = scanResultSchema.parse(raw)
  return {
    ...parsed,
    isbn: parsed.isbn ?? String(isbn),
    format: normalizeBookFormat(parsed.format),
  }
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
