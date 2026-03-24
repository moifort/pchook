import type { AudibleLibraryEntry } from '~/domain/provider/audible/query'
import { AudibleQuery } from '~/domain/provider/audible/query'
import type {
  AudibleImportStatus,
  AudibleSyncState,
  AudibleSyncStatus,
} from '~/domain/provider/audible/types'
import { AUDIBLE_IMPORT_TASK_ID } from '~/domain/provider/audible/use-case'
import { builder } from '~/domain/shared/graphql/builder'

type AuthStartData = {
  loginUrl: string
  sessionId: string
  cookies: { name: string; value: string; domain: string }[]
}

const AuthCookieType = builder
  .objectRef<{ name: string; value: string; domain: string }>('AuthCookie')
  .implement({
    description: 'Audible authentication cookie',
    fields: (t) => ({
      name: t.exposeString('name', { description: 'Cookie name' }),
      value: t.exposeString('value', { description: 'Cookie value' }),
      domain: t.exposeString('domain', { description: 'Cookie domain' }),
    }),
  })

export const AuthStartResponseType = builder
  .objectRef<AuthStartData>('AuthStartResponse')
  .implement({
    description: 'Audible authentication start response',
    fields: (t) => ({
      loginUrl: t.exposeString('loginUrl', { description: 'Audible login URL' }),
      sessionId: t.exposeString('sessionId', {
        description: 'Authentication session identifier',
      }),
      cookies: t.field({
        type: [AuthCookieType],
        description: 'Cookies to send with the login request',
        resolve: ({ cookies }) => cookies,
      }),
    }),
  })

export const AudibleSyncStatusEnum = builder.enumType('AudibleSyncStatus', {
  description: 'Audible synchronization status',
  values: {
    DISCONNECTED: { value: 'disconnected' as const, description: 'Not connected to Audible' },
    CONNECTED: { value: 'connected' as const, description: 'Connected, not yet fetched' },
    FETCHING: { value: 'fetching' as const, description: 'Currently fetching library data' },
    FETCHED: { value: 'fetched' as const, description: 'Library data fetched' },
  },
})

export const AudibleImportStatusEnum = builder.enumType('AudibleImportStatus', {
  description: 'Audible import status',
  values: {
    INIT: { value: 'init' as const, description: 'Not started' },
    IMPORTING: { value: 'importing' as const, description: 'Import in progress' },
    IMPORTED: { value: 'imported' as const, description: 'Import completed' },
  },
})

const AudibleSeriesInfoType = builder
  .objectRef<{ name: string; position?: number }>('AudibleSeriesInfo')
  .implement({
    description: 'Series information for an Audible item',
    fields: (t) => ({
      name: t.exposeString('name', { description: 'Series name' }),
      position: t.field({
        type: 'Int',
        nullable: true,
        description: 'Position in the series',
        resolve: ({ position }) => position ?? null,
      }),
    }),
  })

const AudibleItemType = builder.objectRef<AudibleLibraryEntry>('AudibleItem').implement({
  description: 'An Audible library or wishlist item',
  fields: (t) => ({
    asin: t.field({
      type: 'String',
      description: 'Amazon Standard Identification Number',
      resolve: ({ item }) => String(item.asin),
    }),
    title: t.field({
      type: 'String',
      description: 'Book title',
      resolve: ({ item }) => item.title,
    }),
    authors: t.field({
      type: ['String'],
      description: 'Author names',
      resolve: ({ item }) => item.authors,
    }),
    narrators: t.field({
      type: ['String'],
      description: 'Narrator names',
      resolve: ({ item }) => item.narrators,
    }),
    durationMinutes: t.field({
      type: 'Int',
      description: 'Duration in minutes',
      resolve: ({ item }) => item.durationMinutes,
    }),
    publisher: t.field({
      type: 'String',
      nullable: true,
      description: 'Publisher name',
      resolve: ({ item }) => item.publisher ?? null,
    }),
    language: t.field({
      type: 'String',
      nullable: true,
      description: 'Language',
      resolve: ({ item }) => item.language ?? null,
    }),
    releaseDate: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Release date',
      resolve: ({ item }) => item.releaseDate ?? null,
    }),
    coverUrl: t.field({
      type: 'String',
      nullable: true,
      description: 'Cover image URL',
      resolve: ({ item }) => item.coverUrl ?? null,
    }),
    series: t.field({
      type: AudibleSeriesInfoType,
      nullable: true,
      description: 'Series information',
      resolve: ({ item }) => item.series ?? null,
    }),
    finishedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Date the book was finished listening',
      resolve: ({ item }) => item.finishedAt ?? null,
    }),
    importedBookId: t.field({
      type: 'ID',
      nullable: true,
      description: 'ID of the imported book, if already imported',
      resolve: ({ importedBookId }) => importedBookId ?? null,
    }),
  }),
})

type AudibleSyncData = AudibleSyncState

export const AudibleSyncType = builder.objectRef<AudibleSyncData>('AudibleSync').implement({
  description: 'Audible synchronization state',
  fields: (t) => ({
    status: t.field({
      type: AudibleSyncStatusEnum,
      description: 'Current sync status',
      resolve: ({ syncStatus }) => syncStatus as AudibleSyncStatus,
    }),
    updatedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Last sync state update',
      resolve: ({ syncUpdatedAt }) => syncUpdatedAt ?? null,
    }),
    library: t.field({
      type: [AudibleItemType],
      nullable: true,
      description: 'Library items (null if not yet fetched)',
      resolve: async ({ syncStatus }) => {
        if (syncStatus !== 'fetched') return null
        return AudibleQuery.getLibrary('library')
      },
    }),
    wishlist: t.field({
      type: [AudibleItemType],
      nullable: true,
      description: 'Wishlist items (null if not yet fetched)',
      resolve: async ({ syncStatus }) => {
        if (syncStatus !== 'fetched') return null
        return AudibleQuery.getLibrary('wishlist')
      },
    }),
  }),
})

type AudibleImportData = {
  importStatus: AudibleImportStatus
  importUpdatedAt?: Date
  taskId?: string
  importedCount: number
}

export const AudibleImportType = builder.objectRef<AudibleImportData>('AudibleImport').implement({
  description: 'Audible import state',
  fields: (t) => ({
    status: t.field({
      type: AudibleImportStatusEnum,
      description: 'Current import status',
      resolve: ({ importStatus }) => importStatus as AudibleImportStatus,
    }),
    updatedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Last import state update',
      resolve: ({ importUpdatedAt }) => importUpdatedAt ?? null,
    }),
    taskId: t.field({
      type: 'ID',
      nullable: true,
      description: 'Background task identifier',
      resolve: ({ taskId }) => taskId ?? null,
    }),
    importedCount: t.exposeInt('importedCount', {
      description: 'Number of books imported so far',
    }),
  }),
})

export const AudibleType = builder.objectRef<Record<string, never>>('Audible').implement({
  description: 'Audible integration',
  fields: (t) => ({
    sync: t.field({
      type: AudibleSyncType,
      nullable: true,
      description: 'Synchronization state (null if never synced)',
      resolve: async () => {
        const syncState = await AudibleQuery.getSyncState()
        const rawItems = await AudibleQuery.getAllRawItems()
        if (syncState.syncStatus === 'disconnected' && rawItems.length === 0) return null
        return syncState
      },
    }),
    import: t.field({
      type: AudibleImportType,
      nullable: true,
      description: 'Import state (null if never imported)',
      resolve: async () => {
        const syncState = await AudibleQuery.getSyncState()
        const mappings = await AudibleQuery.getAllMappings()
        if (syncState.importStatus === 'init' && mappings.length === 0) return null
        return {
          importStatus: syncState.importStatus,
          importUpdatedAt: syncState.importUpdatedAt,
          taskId: String(AUDIBLE_IMPORT_TASK_ID),
          importedCount: mappings.length,
        }
      },
    }),
  }),
})
