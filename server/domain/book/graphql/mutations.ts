import { GraphQLError } from 'graphql'
import { BookCommand } from '~/domain/book/command'
import {
  BookFormat,
  BookId,
  BookStatus,
  BookTitle,
  Genre,
  ISBN,
  Language,
  Note,
  PageCount,
  Publisher,
} from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import type { Book } from '~/domain/book/types'
import { BookUseCase } from '~/domain/book/use-case'
import { enrichWithGemini } from '~/domain/scan/scanner'
import { scanResultToBookData } from '~/domain/scan/to-book-data'
import type { ScanResult } from '~/domain/scan/types'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesPosition } from '~/domain/series/primitives'
import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { Eur, PersonName, Url } from '~/domain/shared/primitives'
import { UpdateBookInput } from './inputs'
import { BookType } from './types'

const bookNotFound = () => new GraphQLError('Book not found', { extensions: { code: 'NOT_FOUND' } })

const toBookUpdate = (input: Record<string, unknown>) => ({
  ...(input.title !== undefined && { title: BookTitle(input.title) }),
  ...(input.authors !== undefined && {
    authors: (input.authors as string[]).map((author) => PersonName(author)),
  }),
  ...(input.publisher !== undefined && {
    publisher: input.publisher ? Publisher(input.publisher) : undefined,
  }),
  ...(input.publishedDate !== undefined && {
    publishedDate: input.publishedDate ? new Date(input.publishedDate as string) : undefined,
  }),
  ...(input.pageCount !== undefined && {
    pageCount: input.pageCount ? PageCount(input.pageCount) : undefined,
  }),
  ...(input.genre !== undefined && {
    genre: input.genre ? Genre(input.genre) : undefined,
  }),
  ...(input.synopsis !== undefined && { synopsis: (input.synopsis as string) ?? undefined }),
  ...(input.isbn !== undefined && {
    isbn: input.isbn ? ISBN(input.isbn) : undefined,
  }),
  ...(input.language !== undefined && {
    language: input.language ? Language(input.language) : undefined,
  }),
  ...(input.format !== undefined && {
    format: input.format ? BookFormat(input.format) : undefined,
  }),
  ...(input.translator !== undefined && {
    translator: input.translator ? PersonName(input.translator) : undefined,
  }),
  ...(input.estimatedPrice !== undefined && {
    estimatedPrice: input.estimatedPrice ? Eur(input.estimatedPrice) : undefined,
  }),
  ...(input.duration !== undefined && { duration: (input.duration as string) ?? undefined }),
  ...(input.narrators !== undefined && {
    narrators: input.narrators
      ? (input.narrators as string[]).map((narrator) => PersonName(narrator))
      : undefined,
  }),
  ...(input.personalNotes !== undefined && {
    personalNotes: (input.personalNotes as string) ?? undefined,
  }),
  ...(input.status !== undefined && { status: BookStatus(input.status) }),
  ...(input.readDate !== undefined && {
    readDate: input.readDate ? new Date(input.readDate as string) : undefined,
  }),
  ...(input.awards !== undefined && { awards: input.awards as Book['awards'] }),
  ...(input.publicRatings !== undefined && {
    publicRatings: (
      input.publicRatings as {
        source: string
        score: number
        maxScore: number
        voterCount: number
        url: string
      }[]
    ).map(({ source, score, maxScore, voterCount, url }) => ({
      source,
      score: Note(score),
      maxScore: Note(maxScore),
      voterCount,
      url: Url(url),
    })),
  }),
})

builder.mutationField('updateBook', (t) =>
  t.field({
    type: BookType,
    description: 'Modifier un livre existant',
    args: {
      id: t.arg.id({ required: true, description: 'Identifiant du livre' }),
      input: t.arg({ type: UpdateBookInput, required: true }),
    },
    resolve: async (_, { id, input }) => {
      const bookId = BookId(id)
      const result = await BookCommand.update(bookId, toBookUpdate(input))
      if (result === 'not-found') throw bookNotFound()

      if (input.series !== undefined) {
        await SeriesCommand.removeBook(bookId)
        if (input.series) {
          const series = await SeriesCommand.findOrCreate(input.series)
          const label = SeriesLabel(input.seriesLabel ?? String(input.seriesNumber ?? 1))
          const position = SeriesPosition(input.seriesNumber ?? 1)
          await SeriesCommand.addBook(series.id, bookId, label, position)
        }
      }

      return result
    },
  }),
)

builder.mutationField('deleteBook', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Supprimer un livre et ses données associées (review, série)',
    args: {
      id: t.arg.id({ required: true, description: 'Identifiant du livre à supprimer' }),
    },
    resolve: async (_, { id }) => {
      const result = await BookUseCase.removeCompletely(BookId(id))
      if (result === 'not-found') throw bookNotFound()
      return true
    },
  }),
)

const bookToScanResult = (book: Book, seriesName?: string): ScanResult => ({
  title: String(book.title),
  authors: book.authors.map(String),
  publisher: book.publisher ? String(book.publisher) : undefined,
  publishedDate: book.publishedDate ? book.publishedDate.toISOString().split('T')[0] : undefined,
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

builder.mutationField('refreshBook', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Ré-enrichir un livre via Gemini (met à jour les métadonnées)',
    args: {
      id: t.arg.id({ required: true, description: 'Identifiant du livre' }),
    },
    resolve: async (_, { id }) => {
      const bookId = BookId(id)
      const book = await BookQuery.getById(bookId)
      if (book === 'not-found') throw bookNotFound()

      const existingSeries = await SeriesQuery.getByBookId(book.id)
      const scanResult = bookToScanResult(
        book,
        existingSeries?.name ? String(existingSeries.name) : undefined,
      )
      const allSeries = await SeriesQuery.findAll()
      const seriesNames = allSeries.map(({ name }) => String(name))
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
