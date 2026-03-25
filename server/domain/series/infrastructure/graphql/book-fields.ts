import { BookType } from '~/domain/book/infrastructure/graphql/types'
import type { SeriesInfo } from '~/domain/book/read-model/types'
import { booksInLanguage } from '~/domain/series/business-rules'
import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { SeriesInfoType } from './types'

builder.objectField(BookType, 'series', (t) =>
  t.field({
    type: SeriesInfoType,
    nullable: true,
    description: 'Series information',
    resolve: async ({ id, language }) => {
      const seriesInfo = await SeriesQuery.getByBookId(id)
      if (!seriesInfo) return null

      const fullSeries = await SeriesQuery.getById(seriesInfo.id)
      if (fullSeries === 'not-found') return null

      return {
        id: fullSeries.id,
        name: fullSeries.name,
        label: seriesInfo.label,
        position: seriesInfo.position,
        books: booksInLanguage(fullSeries.books, language).map(
          ({ id, title, label, position }) => ({
            id,
            title,
            label,
            position,
          }),
        ),
      } satisfies SeriesInfo
    },
  }),
)
