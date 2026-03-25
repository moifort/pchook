import { booksInLanguage } from '~/domain/series/business-rules'
import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { SeriesType, SeriesVolumeType } from './types'

builder.objectField(SeriesType, 'volumes', (t) =>
  t.field({
    type: [SeriesVolumeType],
    description: 'All volumes in this series (filtered by language when accessed from a book)',
    resolve: async ({ id, filterLanguage }) => {
      const result = await SeriesQuery.getById(id)
      if (result === 'not-found') return []

      const books = filterLanguage ? booksInLanguage(result.books, filterLanguage) : result.books
      return books.map(({ id, title, label, position }) => ({
        id,
        title,
        label,
        position,
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
      return allSeries.find((series) => series.id === id) ?? null
    },
  }),
)
