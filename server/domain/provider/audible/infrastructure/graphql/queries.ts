import { AudibleQuery } from '~/domain/provider/audible/query'
import { AUDIBLE_IMPORT_TASK_ID } from '~/domain/provider/audible/use-case'
import { builder } from '~/domain/shared/graphql/builder'
import { AudibleSyncType } from './types'

builder.queryField('audibleSync', (t) =>
  t.field({
    type: AudibleSyncType,
    description: 'Audible synchronization status',
    resolve: async () => {
      const syncState = await AudibleQuery.getSyncState()
      const mappings = await AudibleQuery.getAllMappings()
      const rawItems = await AudibleQuery.getAllRawItems()

      const mappedLibrary = mappings.filter(({ source }) => source === 'library').length
      const mappedWishlist = mappings.filter(({ source }) => source === 'wishlist').length
      const rawLibrary = rawItems.filter(({ source }) => source === 'library').length
      const rawWishlist = rawItems.filter(({ source }) => source === 'wishlist').length

      return {
        connected: syncState.syncStatus !== 'disconnected',
        fetchInProgress: syncState.syncStatus === 'fetching',
        libraryCount: Math.max(mappedLibrary, rawLibrary),
        wishlistCount: Math.max(mappedWishlist, rawWishlist),
        lastSyncAt: syncState.importUpdatedAt,
        lastFetchedAt: syncState.syncUpdatedAt,
        rawItemCount: rawItems.length,
        importTaskId: String(AUDIBLE_IMPORT_TASK_ID),
      }
    },
  }),
)
