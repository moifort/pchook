import { AudibleQuery } from '~/domain/provider/audible/query'
import type {
  AsinBookMapping,
  AudibleItem,
  AudibleSyncState,
  RawAudibleEntry,
} from '~/domain/provider/audible/types'
import { AUDIBLE_IMPORT_TASK_ID } from '~/domain/provider/audible/use-case'
import { builder } from '~/domain/shared/graphql/builder'

// --- Auth (infrastructure only, not domain) ---

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

// --- Domain types ---

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

const AudibleItemType = builder.objectRef<AudibleItem>('AudibleItem').implement({
  description: 'An Audible library or wishlist item',
  fields: (t) => ({
    asin: t.field({
      type: 'Asin',
      description: 'Amazon Standard Identification Number',
      resolve: ({ asin }) => asin,
    }),
    title: t.exposeString('title', { description: 'Book title' }),
    authors: t.field({
      type: ['String'],
      description: 'Author names',
      resolve: ({ authors }) => authors,
    }),
    narrators: t.field({
      type: ['String'],
      description: 'Narrator names',
      resolve: ({ narrators }) => narrators,
    }),
    durationMinutes: t.exposeInt('durationMinutes', { description: 'Duration in minutes' }),
    publisher: t.field({
      type: 'String',
      nullable: true,
      description: 'Publisher name',
      resolve: ({ publisher }) => publisher ?? null,
    }),
    language: t.field({
      type: 'String',
      nullable: true,
      description: 'Language',
      resolve: ({ language }) => language ?? null,
    }),
    releaseDate: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Release date',
      resolve: ({ releaseDate }) => releaseDate ?? null,
    }),
    coverUrl: t.field({
      type: 'Url',
      nullable: true,
      description: 'Cover image URL',
      resolve: ({ coverUrl }) => coverUrl ?? null,
    }),
    series: t.field({
      type: AudibleSeriesInfoType,
      nullable: true,
      description: 'Series information',
      resolve: ({ series }) => series ?? null,
    }),
    finishedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Date the book was finished listening',
      resolve: ({ finishedAt }) => finishedAt ?? null,
    }),
  }),
})

const AudibleEntryType = builder.objectRef<RawAudibleEntry>('AudibleEntry').implement({
  description: 'A raw Audible entry with metadata',
  fields: (t) => ({
    item: t.field({
      type: AudibleItemType,
      description: 'Audible item data',
      resolve: ({ item }) => item,
    }),
    source: t.field({
      type: 'AudibleSource',
      description: 'Item source',
      resolve: ({ source }) => source,
    }),
    downloadedAt: t.field({
      type: 'DateTime',
      description: 'Download timestamp',
      resolve: ({ downloadedAt }) => downloadedAt,
    }),
  }),
})

const AsinBookMappingType = builder.objectRef<AsinBookMapping>('AsinBookMapping').implement({
  description: 'Mapping between an Audible ASIN and an imported book',
  fields: (t) => ({
    asin: t.field({
      type: 'Asin',
      description: 'Amazon Standard Identification Number',
      resolve: ({ asin }) => asin,
    }),
    bookId: t.field({
      type: 'BookId',
      description: 'Imported book identifier',
      resolve: ({ bookId }) => bookId,
    }),
    source: t.field({
      type: 'AudibleSource',
      description: 'Item source',
      resolve: ({ source }) => source,
    }),
    syncedAt: t.field({
      type: 'DateTime',
      description: 'Sync timestamp',
      resolve: ({ syncedAt }) => syncedAt,
    }),
  }),
})

// --- Composite types ---

type AudibleSyncData = Pick<AudibleSyncState, 'syncStatus' | 'syncUpdatedAt'>

export const AudibleSyncType = builder.objectRef<AudibleSyncData>('AudibleSync').implement({
  description: 'Audible synchronization state',
  fields: (t) => ({
    status: t.field({
      type: 'AudibleSyncStatus',
      description: 'Current sync status',
      resolve: ({ syncStatus }) => syncStatus,
    }),
    updatedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Last sync state update',
      resolve: ({ syncUpdatedAt }) => syncUpdatedAt ?? null,
    }),
    entries: t.field({
      type: [AudibleEntryType],
      description: 'Fetched Audible entries',
      args: {
        source: t.arg({ type: 'AudibleSource', required: false, description: 'Filter by source' }),
      },
      resolve: async ({ syncStatus }, { source }) => {
        if (syncStatus !== 'fetched') return []
        const rawItems = await AudibleQuery.getAllRawItems()
        return source ? rawItems.filter((entry) => entry.source === source) : rawItems
      },
    }),
  }),
})

type AudibleImportData = Pick<AudibleSyncState, 'importStatus' | 'importUpdatedAt'> & {
  importedCount: number
  mappings: AsinBookMapping[]
}

export const AudibleImportType = builder.objectRef<AudibleImportData>('AudibleImport').implement({
  description: 'Audible import state',
  fields: (t) => ({
    status: t.field({
      type: 'AudibleImportStatus',
      description: 'Current import status',
      resolve: ({ importStatus }) => importStatus,
    }),
    updatedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Last import state update',
      resolve: ({ importUpdatedAt }) => importUpdatedAt ?? null,
    }),
    taskId: t.field({
      type: 'TaskId',
      description: 'Background task identifier',
      resolve: () => AUDIBLE_IMPORT_TASK_ID,
    }),
    importedCount: t.exposeInt('importedCount', {
      description: 'Number of books imported so far',
    }),
    mappings: t.field({
      type: [AsinBookMappingType],
      description: 'ASIN to book mappings',
      resolve: ({ mappings }) => mappings,
    }),
  }),
})

export const AudibleType = builder.objectRef<Record<string, never>>('Audible').implement({
  description: 'Audible integration',
  fields: (t) => ({
    sync: t.field({
      type: AudibleSyncType,
      description: 'Synchronization state',
      resolve: async () => {
        const state = await AudibleQuery.getSyncState()
        return { syncStatus: state.syncStatus, syncUpdatedAt: state.syncUpdatedAt }
      },
    }),
    import: t.field({
      type: AudibleImportType,
      description: 'Import state',
      resolve: async () => {
        const state = await AudibleQuery.getSyncState()
        const mappings = await AudibleQuery.getAllMappings()
        return {
          importStatus: state.importStatus,
          importUpdatedAt: state.importUpdatedAt,
          importedCount: mappings.length,
          mappings,
        }
      },
    }),
  }),
})
