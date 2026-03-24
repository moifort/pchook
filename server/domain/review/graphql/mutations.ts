import { GraphQLError } from 'graphql'
import { FAVORITE_RATING } from '~/domain/book/business-rules'
import { BookCommand } from '~/domain/book/command'
import { BookType } from '~/domain/book/graphql/types'
import { BookId, Note } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { ReviewCommand } from '~/domain/review/command'
import type { Review } from '~/domain/review/types'
import { builder } from '~/domain/shared/graphql/builder'
import { CreateReviewInput } from './inputs'
import { ReviewType } from './types'

const bookNotFound = () => new GraphQLError('Book not found', { extensions: { code: 'NOT_FOUND' } })

builder.mutationField('addToFavorites', (t) =>
  t.field({
    type: BookType,
    description: 'Ajouter un livre aux favoris (note de coup de cœur + statut lu)',
    args: {
      id: t.arg.id({ required: true, description: 'Identifiant du livre' }),
    },
    resolve: async (_, { id }) => {
      const bookId = BookId(id)
      const book = await BookQuery.getById(bookId)
      if (book === 'not-found') throw bookNotFound()

      const review: Review = {
        bookId,
        rating: Note(FAVORITE_RATING),
        readDate: new Date(),
        createdAt: new Date(),
      }

      await ReviewCommand.create(review)
      const updated = await BookCommand.update(bookId, { status: 'read', readDate: new Date() })
      if (updated === 'not-found') throw bookNotFound()

      return updated
    },
  }),
)

builder.mutationField('addReview', (t) =>
  t.field({
    type: ReviewType,
    description: 'Ajouter une critique à un livre (marque le livre comme lu)',
    args: {
      bookId: t.arg.id({ required: true, description: 'Identifiant du livre' }),
      input: t.arg({ type: CreateReviewInput, required: true }),
    },
    resolve: async (_, { bookId: rawId, input }) => {
      const bookId = BookId(rawId)
      const book = await BookQuery.getById(bookId)
      if (book === 'not-found') throw bookNotFound()

      const review: Review = {
        bookId,
        rating: Note(input.rating),
        readDate: input.readDate ? new Date(input.readDate) : undefined,
        reviewNotes: input.reviewNotes ?? undefined,
        createdAt: new Date(),
      }

      await ReviewCommand.create(review)
      await BookCommand.update(bookId, {
        status: 'read',
        readDate: review.readDate ?? new Date(),
      })

      return review
    },
  }),
)
