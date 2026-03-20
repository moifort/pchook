import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  SeriesId as SeriesIdType,
  SeriesLabel as SeriesLabelType,
  SeriesName as SeriesNameType,
  SeriesPosition as SeriesPositionType,
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

export const SeriesLabel = (value: unknown) => {
  const v = z.string().min(1).parse(value)
  return make<SeriesLabelType>()(v)
}

export const SeriesPosition = (value: unknown) => {
  const v = z
    .preprocess((v) => {
      const n = typeof v === 'string' ? Number(v) : v
      return typeof n === 'number' && Number.isFinite(n) ? n : v
    }, z.number().positive())
    .parse(value)
  return make<SeriesPositionType>()(v)
}
