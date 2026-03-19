import type {
  Asin,
  AsinBookMapping,
  AudibleCredentials,
  AuthSession,
  RawAudibleEntry,
  SyncProgress,
} from '~/domain/audible/types'

const credentialsStorage = () => useStorage<AudibleCredentials>('audible-credentials')
const mappingsStorage = () => useStorage<AsinBookMapping>('audible-mappings')
const authSessionsStorage = () => useStorage<AuthSession>('audible-auth-sessions')
const rawItemsStorage = () => useStorage<RawAudibleEntry>('audible-raw')
const syncMetaStorage = () => useStorage<Date>('audible-sync-meta')

export const findCredentials = async () => credentialsStorage().getItem('current')

export const saveCredentials = async (credentials: AudibleCredentials) => {
  await credentialsStorage().setItem('current', credentials)
}

export const removeCredentials = async () => {
  await credentialsStorage().removeItem('current')
}

export const findMapping = async (asin: Asin) => mappingsStorage().getItem(asin)

export const findAllMappings = async () => {
  const keys = await mappingsStorage().getKeys()
  const items = await mappingsStorage().getItems<AsinBookMapping>(keys)
  return items.map(({ value }) => value)
}

export const saveMapping = async (mapping: AsinBookMapping) => {
  await mappingsStorage().setItem(mapping.asin, mapping)
}

export const findAuthSession = async (sessionId: string) => authSessionsStorage().getItem(sessionId)

export const saveAuthSession = async (sessionId: string, session: AuthSession) => {
  await authSessionsStorage().setItem(sessionId, session)
}

export const removeAuthSession = async (sessionId: string) => {
  await authSessionsStorage().removeItem(sessionId)
}

export const saveRawItem = async (asin: Asin, entry: RawAudibleEntry) => {
  await rawItemsStorage().setItem(asin, entry)
}

export const findAllRawItems = async () => {
  const keys = await rawItemsStorage().getKeys()
  const items = await rawItemsStorage().getItems<RawAudibleEntry>(keys)
  return items.map(({ value }) => value)
}

export const clearRawItems = async () => {
  const keys = await rawItemsStorage().getKeys()
  await Promise.all(keys.map((key) => rawItemsStorage().removeItem(key)))
}

export const findSyncCompletedAt = async () => syncMetaStorage().getItem('lastCompletedAt')

export const saveSyncCompletedAt = async (date: Date) => {
  await syncMetaStorage().setItem('lastCompletedAt', date)
}

// In-memory sync progress (not persisted)
let syncProgress: SyncProgress = { phase: 'idle', current: 0, total: 0, message: '' }

export const getSyncProgress = () => syncProgress

export const setSyncProgress = (progress: SyncProgress) => {
  syncProgress = progress
}
