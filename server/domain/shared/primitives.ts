import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  Count as CountType,
  Eur as EurType,
  PersonName as PersonNameType,
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
