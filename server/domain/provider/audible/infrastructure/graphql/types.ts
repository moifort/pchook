import { AudibleQuery } from '~/domain/provider/audible/query'
import type { AudibleSyncState, RawAudibleEntry } from '~/domain/provider/audible/types'
import { AUDIBLE_IMPORT_TASK_ID } from '~/domain/provider/audible/use-case'
import { builder } from '~/domain/shared/graphql/builder'
import { TaskQuery } from '~/domain/task/query'
import type { TaskPhase } from '~/domain/task/types'

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

const AudibleEntryType = builder.objectRef<RawAudibleEntry>('AudibleEntry').implement({
  description: 'An Audible library or wishlist entry',
  fields: (t) => ({
    asin: t.field({
      type: 'Asin',
      description: 'Amazon Standard Identification Number',
      resolve: ({ item }) => item.asin,
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
      type: 'Url',
      nullable: true,
      description: 'Cover image URL',
      resolve: ({ item }) => item.coverUrl ?? null,
    }),
    seriesName: t.field({
      type: 'String',
      nullable: true,
      description: 'Series name',
      resolve: ({ item }) => item.series?.name ?? null,
    }),
    seriesPosition: t.field({
      type: 'SeriesPosition',
      nullable: true,
      description: 'Position in the series',
      resolve: ({ item }) => item.series?.position ?? null,
    }),
    finishedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Date the book was finished listening',
      resolve: ({ item }) => item.finishedAt ?? null,
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
    libraryCount: t.field({
      type: 'Int',
      description: 'Number of library items',
      resolve: async ({ syncStatus }) => {
        if (syncStatus !== 'fetched') return 0
        const items = await AudibleQuery.getAllRawItems()
        return items.filter(({ source }) => source === 'library').length
      },
    }),
    wishlistCount: t.field({
      type: 'Int',
      description: 'Number of wishlist items',
      resolve: async ({ syncStatus }) => {
        if (syncStatus !== 'fetched') return 0
        const items = await AudibleQuery.getAllRawItems()
        return items.filter(({ source }) => source === 'wishlist').length
      },
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
  totalCount: number
  phase: TaskPhase
  current: number
  total: number
  message: string
  startedAt: Date | null
  completedAt: Date | null
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
    importedCount: t.exposeInt('importedCount', {
      description: 'Number of books imported so far',
    }),
    totalCount: t.exposeInt('totalCount', {
      description: 'Total number of library items',
    }),
    delta: t.field({
      type: 'Int',
      description: 'Items remaining to import',
      resolve: ({ totalCount, importedCount }) => totalCount - importedCount,
    }),
    phase: t.exposeString('phase', {
      description: 'Current task phase (idle, running, paused, cancelled, completed, failed)',
    }),
    current: t.exposeInt('current', { description: 'Number of items processed in current run' }),
    total: t.exposeInt('total', { description: 'Total items to process in current run' }),
    message: t.exposeString('message', { description: 'Current progress message' }),
    startedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Import task start date',
      resolve: ({ startedAt }) => startedAt ?? null,
    }),
    completedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Import task completion date',
      resolve: ({ completedAt }) => completedAt ?? null,
    }),
  }),
})

export async function resolveAudibleImport(): Promise<AudibleImportData> {
  const [syncState, mappings, rawItems, taskResult] = await Promise.all([
    AudibleQuery.getSyncState(),
    AudibleQuery.getAllMappings(),
    AudibleQuery.getAllRawItems(),
    TaskQuery.getById(AUDIBLE_IMPORT_TASK_ID),
  ])
  const task =
    taskResult === 'not-found'
      ? {
          phase: 'idle' as const,
          current: 0,
          total: 0,
          message: '',
          startedAt: null,
          completedAt: null,
        }
      : taskResult
  return {
    importStatus: syncState.importStatus,
    importUpdatedAt: syncState.importUpdatedAt,
    importedCount: mappings.length,
    totalCount: rawItems.length,
    phase: task.phase,
    current: task.current,
    total: task.total,
    message: task.message,
    startedAt: task.startedAt,
    completedAt: task.completedAt,
  }
}

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
      resolve: () => resolveAudibleImport(),
    }),
  }),
})
