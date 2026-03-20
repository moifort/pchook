import type { ISBN } from '~/domain/book/types'
import type { CachedIsbnResult } from '~/system/scan/types'
import { createTypedStorage } from '~/system/storage'

const storage = () => createTypedStorage<CachedIsbnResult>('isbn-cache')

export const findBy = (isbn: ISBN) => storage().getItem(isbn)

export const save = async (entry: CachedIsbnResult) => {
  await storage().setItem(String(entry.isbn), entry)
  return entry
}
