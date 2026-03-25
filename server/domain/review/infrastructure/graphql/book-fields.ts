import { BookType } from '~/domain/book/infrastructure/graphql/types'
import { builder } from '~/domain/shared/graphql/builder'
import { ReviewType } from './types'

builder.objectField(BookType, 'review', (t) =>
  t.field({
    type: ReviewType,
    nullable: true,
    description: 'Personal review and rating',
    resolve: ({ id }, _, { loaders }) => loaders.review.load(id),
  }),
)
