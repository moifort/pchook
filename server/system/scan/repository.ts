import type { CachedScanResult, ImageHash } from '~/system/scan/types'
import { createTypedStorage } from '~/system/storage'

const storage = () => createTypedStorage<CachedScanResult>('scan-cache')

export const findBy = (imageHash: ImageHash) => storage().getItem(imageHash)

export const save = async (entry: CachedScanResult) => {
  await storage().setItem(entry.imageHash, entry)
  return entry
}
