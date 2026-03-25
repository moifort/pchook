import type { BookId, BookTitle, Language } from '~/domain/book/types'
import type { Series, SeriesLabel, SeriesPosition } from '~/domain/series/types'
import { builder } from '~/domain/shared/graphql/builder'

export type SeriesShape = Series & { filterLanguage?: Language }

type SeriesVolumeShape = {
  id: BookId
  title: BookTitle
  label: SeriesLabel
  position: SeriesPosition
}

export const SeriesType = builder.objectRef<SeriesShape>('Series').implement({
  description: 'A book series, saga, or cycle (e.g. "Les Rougon-Macquart")',
  fields: (t) => ({
    id: t.id({ description: 'Unique identifier', resolve: ({ id }) => id }),
    name: t.field({
      type: 'SeriesName',
      description: 'Series name (e.g. "Le Sorceleur", "Fondation")',
      resolve: ({ name }) => name,
    }),
    rating: t.field({
      type: 'Note',
      nullable: true,
      description: 'Personal rating for the series (1-10)',
      resolve: ({ rating }) => rating ?? null,
    }),
    createdAt: t.field({
      type: 'DateTime',
      description: 'Date the series was first added to the library',
      resolve: ({ createdAt }) => createdAt,
    }),
  }),
})

export const SeriesVolumeType = builder.objectRef<SeriesVolumeShape>('SeriesVolume').implement({
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
    position: t.field({
      type: 'SeriesPosition',
      description: 'Sort position in series (e.g. 1, 2, 99 for hors-série)',
      resolve: ({ position }) => position,
    }),
    rating: t.field({
      type: 'Note',
      nullable: true,
      description: 'Personal rating of this volume (null if not reviewed)',
      resolve: async ({ id }, _, { loaders }) => {
        const review = await loaders.review.load(id)
        return review?.rating ?? null
      },
    }),
  }),
})
