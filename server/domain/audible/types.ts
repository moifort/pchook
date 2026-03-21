import type { Brand } from 'ts-brand'
import type { BookId } from '~/domain/book/types'

export type Asin = Brand<string, 'Asin'>

export type AudibleLocale =
  | 'fr'
  | 'com'
  | 'co.uk'
  | 'de'
  | 'it'
  | 'es'
  | 'ca'
  | 'com.au'
  | 'in'
  | 'co.jp'

export type AudibleCredentials = {
  accessToken: string
  refreshToken: string
  adpToken: string
  devicePrivateKey: string
  serial: string
  locale: AudibleLocale
  expiresAt: Date
}

export type AudibleItem = {
  asin: Asin
  title: string
  authors: string[]
  narrators: string[]
  durationMinutes: number
  publisher?: string
  language?: string
  releaseDate?: Date
  coverUrl?: string
  series?: { name: string; position?: number }
  isFinished?: boolean
}

export type AsinBookMapping = {
  asin: Asin
  bookId: BookId
  source: 'library' | 'wishlist'
  syncedAt: Date
}

export type AuthSession = {
  codeVerifier: string
  serial: string
  locale: AudibleLocale
  createdAt: Date
}

export type SyncPhase = 'idle' | 'verifying' | 'downloading' | 'importing' | 'paused' | 'done'

export type RawAudibleEntry = {
  item: AudibleItem
  source: 'library' | 'wishlist'
  downloadedAt: Date
}

export type AudibleSummary = {
  libraryTotal: number
  listenedTotal: number
  wishlistTotal: number
}

export type SyncProgress = {
  phase: SyncPhase
  current: number
  total: number
  message: string
}

export type LocaleConfig = {
  domain: string
  marketplaceId: string
  countryCode: string
}

export const AUDIBLE_LOCALES: Record<AudibleLocale, LocaleConfig> = {
  fr: { domain: 'fr', marketplaceId: 'A2728XDNODOQ8T', countryCode: 'fr' },
  com: { domain: 'com', marketplaceId: 'AF2M0KC94RCEA', countryCode: 'us' },
  'co.uk': { domain: 'co.uk', marketplaceId: 'A2I9A3Q2GNFNGQ', countryCode: 'uk' },
  de: { domain: 'de', marketplaceId: 'AN7V1F1VY261K', countryCode: 'de' },
  it: { domain: 'it', marketplaceId: 'A2N7FU2W2BU2ZC', countryCode: 'it' },
  es: { domain: 'es', marketplaceId: 'ALMIKO4SZCSAR', countryCode: 'es' },
  ca: { domain: 'ca', marketplaceId: 'A2CQZ5RBY40XE', countryCode: 'ca' },
  'com.au': { domain: 'com.au', marketplaceId: 'AN7EY7DTAW63G', countryCode: 'au' },
  in: { domain: 'in', marketplaceId: 'AJO3FBRUE6J4S', countryCode: 'in' },
  'co.jp': { domain: 'co.jp', marketplaceId: 'A1QAP3MOU4173J', countryCode: 'jp' },
} as const
