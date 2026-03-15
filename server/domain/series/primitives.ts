import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  Position as PositionType,
  SeriesId as SeriesIdType,
  SeriesName as SeriesNameType,
} from '~/domain/series/types'

export const SeriesId = (value: unknown) => {
  const v = z.string().uuid().parse(value)
  return make<SeriesIdType>()(v)
}

export const randomSeriesId = () => SeriesId(crypto.randomUUID())

export const SeriesName = (value: unknown) => {
  const v = z.string().min(1).parse(value)
  return make<SeriesNameType>()(v)
}

export const Position = (value: unknown) => {
  const v = z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().int().positive())
    .parse(value)
  return make<PositionType>()(v)
}
