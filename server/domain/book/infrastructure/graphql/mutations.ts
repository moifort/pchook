import { GraphQLError } from 'graphql'
import { BookCommand } from '~/domain/book/command'
import { BookFormat, BookStatus } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import type { Book, PublicRating } from '~/domain/book/types'
import { BookUseCase } from '~/domain/book/use-case'
import { formatDuration } from '~/domain/provider/audible/business-rules'
import { enrichWithGemini } from '~/domain/scan/scanner'
import { scanResultToBookData } from '~/domain/scan/to-book-data'
import type { ScanResult } from '~/domain/scan/types'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesPosition } from '~/domain/series/primitives'
import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { Minutes } from '~/domain/shared/primitives'
import { UpdateBookInput } from './inputs'
import { BookType } from './types'

const bookNotFound = () => new GraphQLError('Book not found', { extensions: { code: 'NOT_FOUND' } })

const toBookUpdate = (input: Record<string, unknown>) => ({
  ...(input.title !== undefined && { title: input.title as Book['title'] }),
  ...(input.authors !== undefined && { authors: input.authors as Book['authors'] }),
  ...(input.publisher !== undefined && {
    publisher: (input.publisher as Book['publisher']) ?? undefined,
  }),
  ...(input.publishedDate !== undefined && {
    publishedDate: input.publishedDate ? new Date(input.publishedDate as string) : undefined,
  }),
  ...(input.pageCount !== undefined && {
    pageCount: (input.pageCount as Book['pageCount']) ?? undefined,
  }),
  ...(input.genre !== undefined && {
    genre: (input.genre as Book['genre']) ?? undefined,
  }),
  ...(input.synopsis !== undefined && { synopsis: (input.synopsis as string) ?? undefined }),
  ...(input.isbn !== undefined && {
    isbn: (input.isbn as Book['isbn']) ?? undefined,
  }),
  ...(input.language !== undefined && {
    language: (input.language as Book['language']) ?? undefined,
  }),
  ...(input.format !== undefined && {
    format: input.format ? BookFormat(input.format) : undefined,
  }),
  ...(input.translator !== undefined && {
    translator: (input.translator as Book['translator']) ?? undefined,
  }),
  ...(input.estimatedPrice !== undefined && {
    estimatedPrice: (input.estimatedPrice as Book['estimatedPrice']) ?? undefined,
  }),
  ...(input.durationMinutes !== undefined && {
    durationMinutes: input.durationMinutes != null ? Minutes(input.durationMinutes) : undefined,
  }),
  ...(input.narrators !== undefined && {
    narrators: (input.narrators as Book['narrators']) ?? undefined,
  }),
  ...(input.personalNotes !== undefined && {
    personalNotes: (input.personalNotes as string) ?? undefined,
  }),
  ...(input.recommendedBy !== undefined && {
    recommendedBy: (input.recommendedBy as Book['recommendedBy']) ?? undefined,
  }),
  ...(input.status !== undefined && { status: BookStatus(input.status) }),
  ...(input.readDate !== undefined && {
    readDate: input.readDate ? new Date(input.readDate as string) : undefined,
  }),
  ...(input.awards !== undefined && { awards: input.awards as Book['awards'] }),
  ...(input.publicRatings !== undefined && {
    publicRatings: (input.publicRatings as PublicRating[]).map(
      ({ source, score, maxScore, voterCount, url }) => ({
        source,
        score,
        maxScore,
        voterCount,
        url,
      }),
    ),
  }),
})

builder.mutationField('updateBook', (t) =>
  t.field({
    type: BookType,
    description: 'Update an existing book',
    args: {
      id: t.arg({ type: 'BookId', required: true, description: 'Book ID' }),
      input: t.arg({ type: UpdateBookInput, required: true }),
    },
    resolve: async (_, { id, input }) => {
      const result = await BookCommand.update(id, toBookUpdate(input))
      if (result === 'not-found') throw bookNotFound()

      if (input.series !== undefined) {
        await SeriesCommand.removeBook(id)
        if (input.series) {
          const series = await SeriesCommand.findOrCreate(input.series)
          const label = input.seriesLabel ?? SeriesLabel(String(input.seriesNumber ?? 1))
          const position = input.seriesNumber ?? SeriesPosition(1)
          await SeriesCommand.addBook(series.id, id, label, position)
        }
      }

      return result
    },
  }),
)

builder.mutationField('deleteBook', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Delete a book and its associated data (review, series)',
    args: {
      id: t.arg({ type: 'BookId', required: true, description: 'ID of the book to delete' }),
    },
    resolve: async (_, { id }) => {
      const result = await BookUseCase.removeCompletely(id)
      if (result === 'not-found') throw bookNotFound()
      return true
    },
  }),
)

const bookToScanResult = (book: Book, seriesName?: string): ScanResult => ({
  title: book.title,
  authors: [...book.authors],
  publisher: book.publisher ?? undefined,
  publishedDate: book.publishedDate ? book.publishedDate.toISOString().split('T')[0] : undefined,
  pageCount: book.pageCount ?? undefined,
  genre: book.genre ?? undefined,
  synopsis: book.synopsis,
  isbn: book.isbn ?? undefined,
  language: book.language ?? undefined,
  format: book.format,
  series: seriesName,
  seriesNumber: undefined,
  translator: book.translator ?? undefined,
  estimatedPrice: book.estimatedPrice ?? undefined,
  duration: book.durationMinutes ? formatDuration(book.durationMinutes) : undefined,
  narrators: book.narrators.length > 0 ? [...book.narrators] : undefined,
  awards: book.awards,
  publicRatings: book.publicRatings.map(({ source, score, maxScore, voterCount }) => ({
    source,
    score,
    maxScore,
    voterCount,
  })),
})

builder.mutationField('refreshBook', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Re-enrich a book via Gemini (updates metadata)',
    args: {
      id: t.arg({ type: 'BookId', required: true, description: 'Book ID' }),
    },
    resolve: async (_, { id }) => {
      const book = await BookQuery.getById(id)
      if (book === 'not-found') throw bookNotFound()

      const existingSeries = await SeriesQuery.getByBookId(book.id)
      const scanResult = bookToScanResult(book, existingSeries?.name ?? undefined)
      const allSeries = await SeriesQuery.findAll()
      const seriesNames = allSeries.map(({ name }) => name)
      const enriched = await enrichWithGemini(scanResult, seriesNames)
      const { title, data, seriesInfo } = scanResultToBookData(enriched)

      await BookCommand.update(book.id, { title, ...data })

      await SeriesCommand.removeBook(book.id)
      if (seriesInfo?.name) {
        const series = await SeriesCommand.findOrCreate(seriesInfo.name)
        const label = SeriesLabel(seriesInfo.label ?? String(seriesInfo.number ?? 1))
        const position = SeriesPosition(seriesInfo.number ?? 1)
        await SeriesCommand.addBook(series.id, book.id, label, position)
      }

      return true
    },
  }),
)
