import { GraphQLError } from 'graphql'
import { SeriesCommand } from '~/domain/series/command'
import type { SeriesId } from '~/domain/series/types'
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
