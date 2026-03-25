import { make } from 'ts-brand'
import { z } from 'zod'
import type {
  Asin as AsinType,
  AudibleImportStatus as AudibleImportStatusType,
  AudibleLocale as AudibleLocaleType,
  AudibleSource as AudibleSourceType,
  AudibleSyncStatus as AudibleSyncStatusType,
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

export const AudibleSource = (value: unknown) =>
  z.enum(['library', 'wishlist']).parse(value) as AudibleSourceType

export const AudibleSyncStatus = (value: unknown) =>
  z.enum(['disconnected', 'connected', 'fetching', 'fetched']).parse(value) as AudibleSyncStatusType

export const AudibleImportStatus = (value: unknown) =>
  z.enum(['init', 'importing', 'imported']).parse(value) as AudibleImportStatusType
