import type { CachedUrlImportResult, UrlHash } from '~/system/scan/types'

const storage = () => useStorage('url-import-cache')

export const findBy = (urlHash: UrlHash) => storage().getItem<CachedUrlImportResult>(urlHash)

export const save = async (entry: CachedUrlImportResult) => {
  await storage().setItem(entry.urlHash, entry)
  return entry
}
