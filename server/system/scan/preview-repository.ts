import type { BookPreviewData } from '~/system/scan/types'

const storage = () => useStorage('book-preview')

export const findBy = (previewId: string) => storage().getItem<BookPreviewData>(previewId)

export const save = async (entry: BookPreviewData) => {
  await storage().setItem(entry.previewId, entry)
  return entry
}

export const remove = (previewId: string) => storage().removeItem(previewId)
