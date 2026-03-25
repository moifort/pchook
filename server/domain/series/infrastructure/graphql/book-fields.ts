import { BookType } from '~/domain/book/infrastructure/graphql/types'
import { builder } from '~/domain/shared/graphql/builder'
import { SeriesType, SeriesVolumeType } from './types'

builder.objectField(BookType, 'series', (t) =>
  t.field({
    type: SeriesType,
    nullable: true,
    description: 'Series this book belongs to',
    resolve: async ({ id, language }, _, { loaders }) => {
      const entry = await loaders.seriesBook.load(id)
      if (!entry) return null
      return {
        id: entry.id,
        name: entry.name,
        rating: entry.rating,
        createdAt: entry.createdAt,
        filterLanguage: language,
      }
    },
  }),
)

builder.objectField(BookType, 'seriesVolume', (t) =>
  t.field({
    type: SeriesVolumeType,
    nullable: true,
    description: "This book's volume entry in its series (label and position)",
    resolve: async ({ id, title }, _, { loaders }) => {
      const entry = await loaders.seriesBook.load(id)
      if (!entry) return null
      return { id, title, label: entry.label, position: entry.position }
    },
  }),
)
