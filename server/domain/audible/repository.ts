import type {
  Asin,
  AsinBookMapping,
  AudibleCredentials,
  AuthSession,
  SyncProgress,
} from '~/domain/audible/types'

const credentialsStorage = () => useStorage<AudibleCredentials>('audible-credentials')
const mappingsStorage = () => useStorage<AsinBookMapping>('audible-mappings')
const authSessionsStorage = () => useStorage<AuthSession>('audible-auth-sessions')

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

// In-memory sync progress (not persisted)
let syncProgress: SyncProgress = { phase: 'idle', current: 0, total: 0, message: '' }

export const getSyncProgress = () => syncProgress

export const setSyncProgress = (progress: SyncProgress) => {
  syncProgress = progress
}
