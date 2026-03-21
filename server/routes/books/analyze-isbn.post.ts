import { z } from 'zod'
import { ISBN } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { SeriesQuery } from '~/domain/series/query'
import { IsbnScanner } from '~/system/scan/isbn-scanner'
import * as previewRepository from '~/system/scan/preview-repository'

const bodySchema = z.object({
  isbn: z.string().regex(/^\d{10}(\d{3})?$/),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { isbn: rawIsbn } = bodySchema.parse(body)
  const isbn = ISBN(rawIsbn)

  const existing = await BookQuery.findByISBN(isbn)
  if (existing) {
    setResponseStatus(event, 409)
    return {
      status: 409,
      data: {
        bookId: String(existing.id),
        title: String(existing.title),
        authors: existing.authors.map(String),
      },
    } as const
  }

  const allSeries = await SeriesQuery.findAll()
  const seriesNames = allSeries.map(({ name }) => String(name))
  const scanOutput = await IsbnScanner.scan(isbn, seriesNames)
  const previewId = crypto.randomUUID()

  await previewRepository.save({
    previewId,
    scanResult: scanOutput.result,
    coverImageBase64: scanOutput.coverImageBase64,
    importSource: 'isbn',
    createdAt: new Date(),
  })

  return { status: 200, data: { previewId, ...scanOutput.result } } as const
})
