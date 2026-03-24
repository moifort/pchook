import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { SeriesInfoType, SeriesType } from './types'

builder.queryField('series', (t) =>
  t.field({
    type: [SeriesType],
    description: 'List of all series',
    resolve: () => SeriesQuery.findAll(),
  }),
)

builder.queryField('seriesById', (t) =>
  t.field({
    type: SeriesInfoType,
    nullable: true,
    description: 'Series detail with its books',
    args: {
      id: t.arg.id({ required: true, description: 'Series ID' }),
    },
    resolve: async (_, { id }) => {
      const result = await SeriesQuery.getById(id as never)
      if (result === 'not-found') return null

      return {
        name: String(result.name),
        label: '',
        position: 0,
        books: result.books.map(({ id, title, label, position }) => ({
          id,
          title: String(title),
          label: String(label),
          position: Number(position),
        })),
      }
    },
  }),
)
