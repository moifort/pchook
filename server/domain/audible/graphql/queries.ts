import { AudibleQuery } from '~/domain/audible/query'
import { importRunner } from '~/domain/audible/use-case'
import { builder } from '~/domain/shared/graphql/builder'
import { AudibleStatusType, ImportTaskStateType } from './types'

builder.queryField('audibleStatus', (t) =>
  t.field({
    type: AudibleStatusType,
    description: "Statut de l'intégration Audible",
    resolve: async () => {
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
        connected,
        fetchInProgress: AudibleQuery.isFetchInProgress(),
        libraryCount: Math.max(mappedLibrary, rawLibrary),
        wishlistCount: Math.max(mappedWishlist, rawWishlist),
        lastSyncAt: lastSyncAt ?? undefined,
        lastFetchedAt: lastFetchedAt ?? undefined,
        rawItemCount: rawItems.length,
        importTask,
      }
    },
  }),
)

builder.queryField('importState', (t) =>
  t.field({
    type: ImportTaskStateType,
    description: "État de la tâche d'import Audible",
    resolve: () => importRunner.getState(),
  }),
)
