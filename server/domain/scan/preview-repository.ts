import type { BookPreviewData } from '~/domain/scan/types'
import { createTypedStorage } from '~/system/storage'

const storage = () => createTypedStorage<BookPreviewData>('book-preview')

export const findBy = (previewId: string) => storage().getItem(previewId)

export const save = async (entry: BookPreviewData) => {
  await storage().setItem(entry.previewId, entry)
  return entry
}

export const remove = (previewId: string) => storage().removeItem(previewId)
