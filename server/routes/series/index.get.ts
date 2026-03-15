import { SeriesQuery } from '~/domain/series/query'

export default defineEventHandler(async () => {
  const series = await SeriesQuery.findAll()
  return { status: 200, data: series } as const
})
