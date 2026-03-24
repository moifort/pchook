import { AudibleQuery } from '~/domain/provider/audible/query'
import { AUDIBLE_IMPORT_TASK_ID } from '~/domain/provider/audible/use-case'
import { builder } from '~/domain/shared/graphql/builder'
import { AudibleSyncType } from './types'

builder.queryField('audibleSync', (t) =>
  t.field({
    type: AudibleSyncType,
    description: 'Audible synchronization status',
    resolve: async () => {
      const connected = await AudibleQuery.hasCredentials()
      const mappings = await AudibleQuery.getAllMappings()
      const rawItems = await AudibleQuery.getAllRawItems()
      const lastSyncAt = await AudibleQuery.getSyncCompletedAt()
      const lastFetchedAt = await AudibleQuery.getLastFetchedAt()

      const mappedLibrary = mappings.filter(({ source }) => source === 'library').length
      const mappedWishlist = mappings.filter(({ source }) => source === 'wishlist').length
      const rawLibrary = rawItems.filter(({ source }) => source === 'library').length
      const rawWishlist = rawItems.filter(({ source }) => source === 'wishlist').length

      return {
        connected,
        fetchInProgress: AudibleQuery.isFetchInProgress(),
        libraryCount: Math.max(mappedLibrary, rawLibrary),
        wishlistCount: Math.max(mappedWishlist, rawWishlist),
        lastSyncAt: lastSyncAt ?? undefined,
        lastFetchedAt: lastFetchedAt ?? undefined,
        rawItemCount: rawItems.length,
        importTaskId: String(AUDIBLE_IMPORT_TASK_ID),
      }
    },
  }),
)
