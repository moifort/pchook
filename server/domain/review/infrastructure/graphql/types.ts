import type { Review } from '~/domain/review/types'
import { builder } from '~/domain/shared/graphql/builder'

export const ReviewType = builder.objectRef<Review>('Review').implement({
  description: 'Personal review and rating of a book',
  fields: (t) => ({
    bookId: t.field({
      type: 'BookId',
      description: 'Associated book ID',
      resolve: ({ bookId }) => bookId,
    }),
    rating: t.field({
      type: 'Note',
      description: 'Personal rating (0-5)',
      resolve: ({ rating }) => rating,
    }),
    readDate: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Read date',
      resolve: ({ readDate }) => readDate ?? null,
    }),
    reviewNotes: t.exposeString('reviewNotes', { nullable: true, description: 'Reading notes' }),
    createdAt: t.field({
      type: 'DateTime',
      description: 'Creation date',
      resolve: ({ createdAt }) => createdAt,
    }),
  }),
})
