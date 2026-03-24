import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  Asin as AsinType,
  AudibleLocale as AudibleLocaleType,
} from '~/domain/provider/audible/types'

export const Asin = (value: unknown) => {
  const v = z
    .string()
    .regex(/^[A-Z0-9]{10}$/)
    .parse(value)
  return make<AsinType>()(v)
}

const audibleLocales = [
  'fr',
  'com',
  'co.uk',
  'de',
  'it',
  'es',
  'ca',
  'com.au',
  'in',
  'co.jp',
] as const

export const AudibleLocale = (value: unknown) =>
  z.enum(audibleLocales).parse(value) as AudibleLocaleType
