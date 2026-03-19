import { AudibleQuery } from '~/domain/audible/query'

export default defineEventHandler(async () => {
  const connected = await AudibleQuery.hasCredentials()
  const mappings = await AudibleQuery.getAllMappings()
  const rawItems = await AudibleQuery.getAllRawItems()
  const lastSyncAt = await AudibleQuery.getSyncCompletedAt()

  const mappedLibrary = mappings.filter(({ source }) => source === 'library').length
  const mappedWishlist = mappings.filter(({ source }) => source === 'wishlist').length
  const rawLibrary = rawItems.filter(({ source }) => source === 'library').length
  const rawWishlist = rawItems.filter(({ source }) => source === 'wishlist').length

  return {
    status: 200,
    data: {
      connected,
      libraryCount: Math.max(mappedLibrary, rawLibrary),
      wishlistCount: Math.max(mappedWishlist, rawWishlist),
      lastSyncAt,
      rawItemCount: rawItems.length,
    },
  } as const
})
