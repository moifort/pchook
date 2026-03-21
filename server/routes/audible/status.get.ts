import { AudibleQuery } from '~/domain/audible/query'
import { importRunner } from '~/domain/audible/use-case'

export default defineEventHandler(async () => {
  const connected = await AudibleQuery.hasCredentials()
  const mappings = await AudibleQuery.getAllMappings()
  const rawItems = await AudibleQuery.getAllRawItems()
  const lastSyncAt = await AudibleQuery.getSyncCompletedAt()
  const lastFetchedAt = await AudibleQuery.getLastFetchedAt()
  const importTask = await importRunner.getState()

  const mappedLibrary = mappings.filter(({ source }) => source === 'library').length
  const mappedWishlist = mappings.filter(({ source }) => source === 'wishlist').length
  const rawLibrary = rawItems.filter(({ source }) => source === 'library').length
  const rawWishlist = rawItems.filter(({ source }) => source === 'wishlist').length

  return {
    status: 200,
    data: {
      connected,
      fetchInProgress: AudibleQuery.isFetchInProgress(),
      libraryCount: Math.max(mappedLibrary, rawLibrary),
      wishlistCount: Math.max(mappedWishlist, rawWishlist),
      lastSyncAt,
      lastFetchedAt,
      rawItemCount: rawItems.length,
      importTask,
    },
  } as const
})
