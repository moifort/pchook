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
import type { Award, PublicRating } from '~/domain/book/types'
import { Eur, PersonName } from '~/domain/shared/primitives'

export default defineEventHandler(async (event) => {
  const id = BookId(getRouterParam(event, 'id'))
  const body = await readBody(event)
  if (!body) throw createError({ statusCode: 400, statusMessage: 'No body provided' })

  const data = {
    ...(body.title !== undefined && { title: BookTitle(body.title) }),
    ...(body.authors !== undefined && {
      authors: (body.authors as unknown[]).map((a) => PersonName(a)),
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
    ...(body.synopsis !== undefined && { synopsis: body.synopsis as string | undefined }),
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
    ...(body.duration !== undefined && { duration: body.duration as string | undefined }),
    ...(body.narrators !== undefined && {
      narrators: body.narrators
        ? (body.narrators as unknown[]).map((n) => PersonName(n))
        : undefined,
    }),
    ...(body.personalNotes !== undefined && {
      personalNotes: body.personalNotes as string | undefined,
    }),
    ...(body.status !== undefined && { status: BookStatus(body.status) }),
    ...(body.readDate !== undefined && {
      readDate: body.readDate ? new Date(body.readDate) : undefined,
    }),
    ...(body.awards !== undefined && { awards: body.awards as Award[] }),
    ...(body.publicRatings !== undefined && {
      publicRatings: (
        body.publicRatings as {
          source: string
          score: unknown
          maxScore: unknown
          voterCount: number
        }[]
      ).map(({ source, score, maxScore, voterCount }) => ({
        source,
        score: Note(score),
        maxScore: Note(maxScore),
        voterCount,
      })) as PublicRating[],
    }),
  }

  const result = await BookCommand.update(id, data)

  if (result === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Book not found' })
  }

  return { status: 200, data: result } as const
})
