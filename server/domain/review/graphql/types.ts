import type { Review } from '~/domain/review/types'
import { builder } from '~/domain/shared/graphql/builder'

export const ReviewType = builder.objectRef<Review>('Review').implement({
  description: "Critique et note personnelle d'un livre",
  fields: (t) => ({
    bookId: t.id({
      description: 'Identifiant du livre associé',
      resolve: ({ bookId }) => String(bookId),
    }),
    rating: t.int({
      description: 'Note personnelle (0-10)',
      resolve: ({ rating }) => Number(rating),
    }),
    readDate: t.string({
      nullable: true,
      description: 'Date de lecture (ISO 8601)',
      resolve: ({ readDate }) => readDate?.toISOString() ?? null,
    }),
    reviewNotes: t.exposeString('reviewNotes', { nullable: true, description: 'Notes de lecture' }),
    createdAt: t.string({
      description: 'Date de création (ISO 8601)',
      resolve: ({ createdAt }) => createdAt.toISOString(),
    }),
  }),
})
