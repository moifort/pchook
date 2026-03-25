import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  Count as CountType,
  Eur as EurType,
  Minutes as MinutesType,
  PersonName as PersonNameType,
  Url as UrlType,
} from '~/domain/shared/types'

export const Eur = (value: unknown) => {
  const v = z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().nonnegative())
    .parse(value)
  return make<EurType>()(v)
}

export const PersonName = (value: unknown) => {
  const v = z.string().min(1).max(200).parse(value)
  return make<PersonNameType>()(v)
}

export const Count = (value: number) => make<CountType>()(value)

export const Url = (value: unknown) => {
  const v = z.string().url().parse(value)
  return make<UrlType>()(v)
}

export const Minutes = (value: unknown) => {
  const v = z
    .preprocess((v) => (typeof v === 'string' ? Number(v) : v), z.number().int().nonnegative())
    .parse(value)
  return make<MinutesType>()(v)
}

export const parseDuration = (duration: string) => {
  const match = duration.match(/(?:(\d+)h)?\s*(?:(\d+)min)?/)
  if (!match || (!match[1] && !match[2])) return undefined
  const hours = Number(match[1] ?? 0)
  const minutes = Number(match[2] ?? 0)
  const total = hours * 60 + minutes
  return total > 0 ? Minutes(total) : undefined
}
