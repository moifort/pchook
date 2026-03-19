import { z } from 'zod'
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
import { SeriesCommand } from '~/domain/series/command'
import { Position } from '~/domain/series/primitives'
import { Eur, PersonName } from '~/domain/shared/primitives'

const bodySchema = z.object({
  title: z.string().min(1).optional(),
  authors: z.array(z.string().min(1)).optional(),
  publisher: z.string().min(1).nullable().optional(),
  publishedDate: z.string().nullable().optional(),
  pageCount: z.number().int().positive().nullable().optional(),
  genre: z.string().min(1).nullable().optional(),
  synopsis: z.string().nullable().optional(),
  isbn: z.string().min(10).max(17).nullable().optional(),
  language: z.string().min(1).nullable().optional(),
  format: z.enum(['pocket', 'paperback', 'hardcover', 'audiobook']).nullable().optional(),
  translator: z.string().min(1).nullable().optional(),
  estimatedPrice: z.number().nonnegative().nullable().optional(),
  duration: z.string().nullable().optional(),
  narrators: z.array(z.string().min(1)).nullable().optional(),
  personalNotes: z.string().nullable().optional(),
  status: z.enum(['to-read', 'read']).optional(),
  readDate: z.string().nullable().optional(),
  awards: z
    .array(
      z.object({
        name: z.string().min(1),
        year: z.number().int().positive().optional(),
      }),
    )
    .optional(),
  publicRatings: z
    .array(
      z.object({
        source: z.string().min(1),
        score: z.unknown(),
        maxScore: z.unknown(),
        voterCount: z.number().int().nonnegative(),
      }),
    )
    .optional(),
  series: z.string().min(1).nullable().optional(),
  seriesNumber: z.number().int().positive().optional(),
})

export default defineEventHandler(async (event) => {
  const id = BookId(getRouterParam(event, 'id'))
  const body = bodySchema.parse(await readBody(event))

  const data = {
    ...(body.title !== undefined && { title: BookTitle(body.title) }),
    ...(body.authors !== undefined && {
      authors: body.authors.map((author) => PersonName(author)),
    }),
    ...(body.publisher !== undefined && {
      publisher: body.publisher ? Publisher(body.publisher) : undefined,
    }),
    ...(body.publishedDate !== undefined && {
      publishedDate: body.publishedDate ? new Date(body.publishedDate) : undefined,
    }),
    ...(body.pageCount !== undefined && {
      pageCount: body.pageCount ? PageCount(body.pageCount) : undefined,
    }),
    ...(body.genre !== undefined && { genre: body.genre ? Genre(body.genre) : undefined }),
    ...(body.synopsis !== undefined && { synopsis: body.synopsis ?? undefined }),
    ...(body.isbn !== undefined && { isbn: body.isbn ? ISBN(body.isbn) : undefined }),
    ...(body.language !== undefined && {
      language: body.language ? Language(body.language) : undefined,
    }),
    ...(body.format !== undefined && {
      format: body.format ? BookFormat(body.format) : undefined,
    }),
    ...(body.translator !== undefined && {
      translator: body.translator ? PersonName(body.translator) : undefined,
    }),
    ...(body.estimatedPrice !== undefined && {
      estimatedPrice: body.estimatedPrice ? Eur(body.estimatedPrice) : undefined,
    }),
    ...(body.duration !== undefined && { duration: body.duration ?? undefined }),
    ...(body.narrators !== undefined && {
      narrators: body.narrators
        ? body.narrators.map((narrator) => PersonName(narrator))
        : undefined,
    }),
    ...(body.personalNotes !== undefined && {
      personalNotes: body.personalNotes ?? undefined,
    }),
    ...(body.status !== undefined && { status: BookStatus(body.status) }),
    ...(body.readDate !== undefined && {
      readDate: body.readDate ? new Date(body.readDate) : undefined,
    }),
    ...(body.awards !== undefined && { awards: body.awards }),
    ...(body.publicRatings !== undefined && {
      publicRatings: body.publicRatings.map(({ source, score, maxScore, voterCount }) => ({
        source,
        score: Note(score),
        maxScore: Note(maxScore),
        voterCount,
      })),
    }),
  }

  const result = await BookCommand.update(id, data)

  if (result === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Book not found' })
  }

  if (body.series !== undefined) {
    await SeriesCommand.removeBook(id)
    if (body.series) {
      const series = await SeriesCommand.findOrCreate(body.series)
      await SeriesCommand.addBook(series.id, id, Position(body.seriesNumber ?? 1))
    }
  }

  return { status: 200, data: result } as const
})
