import { AudibleQuery } from '~/domain/audible/query'

export default defineEventHandler(async () => {
  const connected = await AudibleQuery.hasCredentials()
  const mappings = await AudibleQuery.getAllMappings()
  const libraryCount = mappings.filter(({ source }) => source === 'library').length
  const wishlistCount = mappings.filter(({ source }) => source === 'wishlist').length
  const lastSyncAt =
    mappings.length > 0
      ? new Date(Math.max(...mappings.map(({ syncedAt }) => new Date(syncedAt).getTime())))
      : undefined

  return {
    status: 200,
    data: { connected, libraryCount, wishlistCount, lastSyncAt },
  } as const
})
