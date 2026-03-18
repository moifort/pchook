import type { ISBN } from '~/domain/book/types'
import type { CachedIsbnResult } from '~/system/scan/types'

const storage = () => useStorage('isbn-cache')

export const findBy = (isbn: ISBN) => storage().getItem<CachedIsbnResult>(isbn)

export const save = async (entry: CachedIsbnResult) => {
  await storage().setItem(String(entry.isbn), entry)
  return entry
}
