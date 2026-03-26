import { SearchQuery } from '~/domain/search/query'
import { builder } from '~/domain/shared/graphql/builder'
import { SearchResultsType } from './types'

builder.queryField('search', (t) =>
  t.field({
    type: SearchResultsType,
    description: 'Search across books, series, and authors',
    args: {
      query: t.arg.string({ required: true, description: 'Search query text' }),
      limit: t.arg.int({ description: 'Max results per category (default 10)', defaultValue: 10 }),
    },
    resolve: (_, { query, limit }) => SearchQuery.search(query, limit ?? 10),
  }),
)
