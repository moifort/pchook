import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { SeriesBookEntryType, SeriesType } from './types'

builder.objectField(SeriesType, 'books', (t) =>
  t.field({
    type: [SeriesBookEntryType],
    description: 'All books in this series',
    resolve: async ({ id }) => {
      const result = await SeriesQuery.getById(id)
      if (result === 'not-found') return []

      return result.books.map(({ id, title, label, position }) => ({
        id,
        title: String(title),
        label: String(label),
        position: Number(position),
      }))
    },
  }),
)

builder.queryField('series', (t) =>
  t.field({
    type: [SeriesType],
    description: 'List of all series',
    resolve: () => SeriesQuery.findAll(),
  }),
)

builder.queryField('seriesById', (t) =>
  t.field({
    type: SeriesType,
    nullable: true,
    description: 'Series detail by ID',
    args: {
      id: t.arg.id({ required: true, description: 'Series ID' }),
    },
    resolve: async (_, { id }) => {
      const allSeries = await SeriesQuery.findAll()
      return allSeries.find((series) => String(series.id) === id) ?? null
    },
  }),
)
