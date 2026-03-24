import { BookType } from '~/domain/book/infrastructure/graphql/types'
import { ReviewQuery } from '~/domain/review/query'
import { builder } from '~/domain/shared/graphql/builder'
import { ReviewType } from './types'

builder.objectField(BookType, 'review', (t) =>
  t.field({
    type: ReviewType,
    nullable: true,
    description: 'Personal review and rating',
    resolve: async ({ id }) => {
      const result = await ReviewQuery.getByBookId(id)
      return result === 'not-found' ? null : result
    },
  }),
)
