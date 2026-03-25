import type { SeriesInfo } from '~/domain/book/read-model/types'
import type { Series } from '~/domain/series/types'
import { builder } from '~/domain/shared/graphql/builder'

export const SeriesType = builder.objectRef<Series>('Series').implement({
  description: 'A book series, saga, or cycle (e.g. "Les Rougon-Macquart")',
  fields: (t) => ({
    id: t.id({ description: 'Unique identifier', resolve: ({ id }) => id }),
    name: t.field({
      type: 'SeriesName',
      description: 'Series name (e.g. "Le Sorceleur", "Fondation")',
      resolve: ({ name }) => name,
    }),
    createdAt: t.field({
      type: 'DateTime',
      description: 'Date the series was first added to the library',
      resolve: ({ createdAt }) => createdAt,
    }),
  }),
})

export const SeriesVolumeType = builder
  .objectRef<SeriesInfo['books'][number]>('SeriesVolume')
  .implement({
    description: 'A volume within a series, representing a single book',
    fields: (t) => ({
      id: t.id({
        description: 'Book ID (can be used to fetch full Book details)',
        resolve: ({ id }) => id,
      }),
      title: t.exposeString('title', { description: 'Book title' }),
      label: t.exposeString('label', {
        description: 'Display label in series (e.g. "1", "1.5", "Hors-série", "Préquelle")',
      }),
      position: t.exposeInt('position', {
        description: 'Sort position in series (e.g. 1, 2, 99 for hors-série)',
      }),
    }),
  })

export const SeriesInfoType = builder.objectRef<SeriesInfo>('SeriesInfo').implement({
  description: 'Series context for a specific book, including its position and sibling volumes',
  fields: (t) => ({
    id: t.id({ description: 'Series ID', resolve: ({ id }) => id }),
    name: t.exposeString('name', { description: 'Series name' }),
    label: t.exposeString('label', {
      description: 'This book display label in the series (e.g. "Tome 3")',
    }),
    position: t.exposeInt('position', {
      description: 'This book sort position in the series',
    }),
    volumes: t.field({
      type: [SeriesVolumeType],
      description: 'All volumes in the series, filtered to the same language as this book',
      resolve: ({ books }) => books,
    }),
  }),
})
