import type { SeriesInfo } from '~/domain/book/read-model/types'
import type { Series } from '~/domain/series/types'
import { builder } from '~/domain/shared/graphql/builder'

export const SeriesType = builder.objectRef<Series>('Series').implement({
  description: 'A book series',
  fields: (t) => ({
    id: t.id({ description: 'Unique identifier', resolve: ({ id }) => String(id) }),
    name: t.string({ description: 'Series name', resolve: ({ name }) => String(name) }),
    createdAt: t.string({
      description: 'Creation date (ISO 8601)',
      resolve: ({ createdAt }) => createdAt.toISOString(),
    }),
  }),
})

const SeriesBookEntryType = builder
  .objectRef<SeriesInfo['books'][number]>('SeriesBookEntry')
  .implement({
    description: 'A book entry within a series',
    fields: (t) => ({
      id: t.id({ description: 'Book ID', resolve: ({ id }) => String(id) }),
      title: t.exposeString('title', { description: 'Book title' }),
      label: t.exposeString('label', { description: 'Label in series (e.g. Volume 3)' }),
      position: t.exposeInt('position', { description: 'Position in series' }),
    }),
  })

export const SeriesInfoType = builder.objectRef<SeriesInfo>('SeriesInfo').implement({
  description: 'Information about the series a book belongs to',
  fields: (t) => ({
    name: t.exposeString('name', { description: 'Series name' }),
    label: t.exposeString('label', { description: 'Book label in series' }),
    position: t.exposeInt('position', { description: 'Book position in series' }),
    books: t.field({
      type: [SeriesBookEntryType],
      description: 'All books in the series (same language)',
      resolve: ({ books }) => books,
    }),
  }),
})
