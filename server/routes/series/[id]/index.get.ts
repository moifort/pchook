import { SeriesId } from '~/domain/series/primitives'
import { SeriesQuery } from '~/domain/series/query'

export default defineEventHandler(async (event) => {
  const id = SeriesId(getRouterParam(event, 'id'))
  const result = await SeriesQuery.getById(id)

  if (result === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Series not found' })
  }

  return { status: 200, data: result } as const
})
