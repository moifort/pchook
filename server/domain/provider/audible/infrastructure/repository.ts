import type {
  Asin,
  AsinBookMapping,
  AudibleCredentials,
  AudibleSyncState,
  AuthSession,
  RawAudibleEntry,
} from '~/domain/provider/audible/types'
import { createTypedStorage } from '~/system/storage'

const credentialsStorage = () => createTypedStorage<AudibleCredentials>('audible-credentials')
const mappingsStorage = () => createTypedStorage<AsinBookMapping>('audible-mappings')
const authSessionsStorage = () => createTypedStorage<AuthSession>('audible-auth-sessions')
const rawItemsStorage = () => createTypedStorage<RawAudibleEntry>('audible-raw')
const syncStateStorage = () => createTypedStorage<AudibleSyncState>('audible-sync-meta')

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
  const items = await mappingsStorage().getItems(keys)
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
  const items = await rawItemsStorage().getItems(keys)
  return items.map(({ value }) => value)
}

export const clearRawItems = async () => {
  const keys = await rawItemsStorage().getKeys()
  await Promise.all(keys.map((key) => rawItemsStorage().removeItem(key)))
}

export const clearMappings = async () => {
  const keys = await mappingsStorage().getKeys()
  await Promise.all(keys.map((key) => mappingsStorage().removeItem(key)))
}

export const findSyncState = async () => syncStateStorage().getItem('state')

export const saveSyncState = async (state: AudibleSyncState) => {
  await syncStateStorage().setItem('state', state)
}
