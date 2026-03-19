import { BookCommand } from '~/domain/book/command'
import { BookId } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import type { Book } from '~/domain/book/types'
import { SeriesCommand } from '~/domain/series/command'
import { Position } from '~/domain/series/primitives'
import { SeriesQuery } from '~/domain/series/query'
import { enrichWithGemini } from '~/system/scan/index'
import { scanResultToBookData } from '~/system/scan/to-book-data'
import type { ScanResult } from '~/system/scan/types'

const bookToScanResult = (book: Book, seriesName?: string): ScanResult => ({
  title: String(book.title),
  authors: book.authors.map(String),
  publisher: book.publisher ? String(book.publisher) : undefined,
  publishedDate: book.publishedDate?.toISOString().split('T')[0],
  pageCount: book.pageCount ? Number(book.pageCount) : undefined,
  genre: book.genre ? String(book.genre) : undefined,
  synopsis: book.synopsis,
  isbn: book.isbn ? String(book.isbn) : undefined,
  language: book.language ? String(book.language) : undefined,
  format: book.format,
  series: seriesName,
  seriesNumber: undefined,
  translator: book.translator ? String(book.translator) : undefined,
  estimatedPrice: book.estimatedPrice ? Number(book.estimatedPrice) : undefined,
  duration: book.duration,
  narrators: book.narrators.length > 0 ? book.narrators.map(String) : undefined,
  awards: book.awards,
  publicRatings: book.publicRatings.map(({ source, score, maxScore, voterCount }) => ({
    source,
    score: Number(score),
    maxScore: Number(maxScore),
    voterCount,
  })),
})

export default defineEventHandler(async (event) => {
  const id = BookId(getRouterParam(event, 'id'))
  const book = await BookQuery.getById(id)
  if (book === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Book not found' })
  }

  const existingSeries = await SeriesQuery.getByBookId(book.id)
  const scanResult = bookToScanResult(
    book,
    existingSeries?.name ? String(existingSeries.name) : undefined,
  )
  const enriched = await enrichWithGemini(scanResult)
  const { title, data, seriesInfo } = scanResultToBookData(enriched)

  await BookCommand.update(book.id, {
    title,
    ...data,
  })

  await SeriesCommand.removeBook(book.id)
  if (seriesInfo?.name) {
    const series = await SeriesCommand.findOrCreate(seriesInfo.name)
    await SeriesCommand.addBook(series.id, book.id, Position(seriesInfo.number ?? 1))
  }

  return { status: 200, data: { refreshed: true } } as const
})
