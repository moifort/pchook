import { BookType } from '~/domain/book/graphql/types'
import { ReviewQuery } from '~/domain/review/query'
import { builder } from '~/domain/shared/graphql/builder'
import { ReviewType } from './types'

builder.objectField(BookType, 'review', (t) =>
  t.field({
    type: ReviewType,
    nullable: true,
    description: 'Critique et note personnelle',
    resolve: async ({ id }) => {
      const result = await ReviewQuery.getByBookId(id)
      return result === 'not-found' ? null : result
    },
  }),
)
