import type { Brand } from 'ts-brand'
import type { BookId } from '~/domain/book/types'
import type { Url } from '~/domain/shared/types'

export type { AudibleCredentials, AudibleLocale, AuthSession } from 'audible-api-ts'
export { AUDIBLE_LOCALES } from 'audible-api-ts'

export type Asin = Brand<string, 'Asin'>

export type AudibleItem = {
  asin: Asin
  title: string
  authors: string[]
  narrators: string[]
  durationMinutes: number
  publisher?: string
  language?: string
  releaseDate?: Date
  coverUrl?: Url
  series?: { name: string; position?: number }
  finishedAt?: Date
}

export type AsinBookMapping = {
  asin: Asin
  bookId: BookId
  source: AudibleSource
  syncedAt: Date
}

export type RawAudibleEntry = {
  item: AudibleItem
  source: AudibleSource
  downloadedAt: Date
}

export type AudibleSummary = {
  libraryTotal: number
  listenedTotal: number
  wishlistTotal: number
}

export type AudibleSource = 'library' | 'wishlist'
export type AudibleSyncStatus = 'disconnected' | 'connected' | 'fetching' | 'fetched'
export type AudibleImportStatus = 'init' | 'importing' | 'imported'

export type AudibleSyncState = {
  syncStatus: AudibleSyncStatus
  syncUpdatedAt?: Date
  importStatus: AudibleImportStatus
  importUpdatedAt?: Date
}
