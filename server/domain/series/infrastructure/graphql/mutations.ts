import { GraphQLError } from 'graphql'
import { indexSeries } from '~/domain/search/index'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesQuery } from '~/domain/series/query'
import type { SeriesId, SeriesName } from '~/domain/series/types'
import { builder } from '~/domain/shared/graphql/builder'
import { SeriesType } from './types'

builder.mutationField('rateSeries', (t) =>
  t.field({
    type: SeriesType,
    description: 'Rate a series (personal rating)',
    args: {
      id: t.arg.id({ required: true, description: 'Series ID' }),
      rating: t.arg({ type: 'Note', required: true, description: 'Rating (1-10)' }),
    },
    resolve: async (_, { id, rating }) => {
      const result = await SeriesCommand.rateSeries(id as SeriesId, rating)
      if (result === 'not-found') {
        throw new GraphQLError('Series not found', { extensions: { code: 'NOT_FOUND' } })
      }
      return result
    },
  }),
)

builder.mutationField('renameSeries', (t) =>
  t.field({
    type: SeriesType,
    description: 'Rename a series',
    args: {
      id: t.arg.id({ required: true, description: 'Series ID' }),
      name: t.arg({ type: 'SeriesName', required: true, description: 'New series name' }),
    },
    resolve: async (_, { id, name }) => {
      const result = await SeriesCommand.renameSeries(id as SeriesId, name as SeriesName)
      if (result === 'not-found') {
        throw new GraphQLError('Series not found', { extensions: { code: 'NOT_FOUND' } })
      }
      if (result === 'name-taken') {
        throw new GraphQLError('A series with this name already exists', {
          extensions: { code: 'NAME_TAKEN' },
        })
      }
      const detail = await SeriesQuery.getById(result.id)
      const volumeCount = detail === 'not-found' ? 0 : detail.books.length
      indexSeries({ id: result.id, name: result.name, volumeCount, rating: result.rating })
      return result
    },
  }),
)
