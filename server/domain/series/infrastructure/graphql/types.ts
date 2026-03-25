import type { SeriesInfo } from '~/domain/book/read-model/types'
import type { Series } from '~/domain/series/types'
import { builder } from '~/domain/shared/graphql/builder'

export const SeriesType = builder.objectRef<Series>('Series').implement({
  description: 'A book series',
  fields: (t) => ({
    id: t.id({ description: 'Unique identifier', resolve: ({ id }) => id }),
    name: t.field({
      type: 'SeriesName',
      description: 'Series name',
      resolve: ({ name }) => name,
    }),
    createdAt: t.field({
      type: 'DateTime',
      description: 'Creation date',
      resolve: ({ createdAt }) => createdAt,
    }),
  }),
})

export const SeriesVolumeType = builder
  .objectRef<SeriesInfo['books'][number]>('SeriesVolume')
  .implement({
    description: 'A volume within a series',
    fields: (t) => ({
      id: t.id({ description: 'Book ID', resolve: ({ id }) => id }),
      title: t.exposeString('title', { description: 'Book title' }),
      label: t.exposeString('label', { description: 'Label in series (e.g. Volume 3)' }),
      position: t.exposeInt('position', { description: 'Position in series' }),
    }),
  })

export const SeriesInfoType = builder.objectRef<SeriesInfo>('SeriesInfo').implement({
  description: 'Information about the series a book belongs to',
  fields: (t) => ({
    id: t.id({ description: 'Series ID', resolve: ({ id }) => id }),
    name: t.exposeString('name', { description: 'Series name' }),
    label: t.exposeString('label', { description: 'This book label in series' }),
    position: t.exposeInt('position', { description: 'This book position in series' }),
    volumes: t.field({
      type: [SeriesVolumeType],
      description: 'All volumes in the series (same language)',
      resolve: ({ books }) => books,
    }),
  }),
})
