import type { Brand } from 'ts-brand'
import type { ImportSource, ISBN } from '~/domain/book/types'
import type { Url } from '~/domain/shared/types'

export type ImageHash = Brand<string, 'ImageHash'>
export type UrlHash = Brand<string, 'UrlHash'>

export type ScanResult = {
  title: string
  authors: string[]
  publisher?: string
  publishedDate?: string
  pageCount?: number
  genre?: string
  synopsis?: string
  isbn?: string
  language?: string
  format?: string
  series?: string
  seriesLabel?: string
  seriesNumber?: number
  translator?: string
  estimatedPrice?: number
  duration?: string
  narrators?: string[]
  awards: { name: string; year?: number }[]
  publicRatings: {
    source: string
    score: number
    maxScore: number
    voterCount: number
  }[]
}

export type CachedScanResult = {
  imageHash: ImageHash
  result: ScanResult
  cachedAt: Date
}

export type CachedUrlImportResult = {
  urlHash: UrlHash
  result: ScanResult
  cachedAt: Date
}

export type CachedIsbnResult = {
  isbn: ISBN
  result: ScanResult
  cachedAt: Date
}

export type BookPreviewData = {
  previewId: string
  scanResult: ScanResult
  coverImageBase64?: string
  importSource?: ImportSource
  externalUrl?: Url
  createdAt: Date
}
