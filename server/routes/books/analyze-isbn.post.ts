import { z } from 'zod'
import { ISBN } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
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

  const scanResult = await IsbnScanner.scan(isbn)
  const previewId = crypto.randomUUID()

  await previewRepository.save({
    previewId,
    scanResult,
    importSource: 'isbn',
    createdAt: new Date(),
  })

  return { status: 200, data: { previewId, ...scanResult } } as const
})
