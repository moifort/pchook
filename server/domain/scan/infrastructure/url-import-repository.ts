import type { CachedUrlImportResult, UrlHash } from '~/domain/scan/types'
import { createTypedStorage } from '~/system/storage'

const storage = () => createTypedStorage<CachedUrlImportResult>('url-import-cache')

export const findBy = (urlHash: UrlHash) => storage().getItem(urlHash)

export const save = async (entry: CachedUrlImportResult) => {
  await storage().setItem(entry.urlHash, entry)
  return entry
}
