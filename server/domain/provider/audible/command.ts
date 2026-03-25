import * as repository from '~/domain/provider/audible/infrastructure/repository'
import type {
  Asin,
  AsinBookMapping,
  AudibleCredentials,
  AudibleSyncState,
  AuthSession,
  RawAudibleEntry,
} from '~/domain/provider/audible/types'

const DEFAULT_SYNC_STATE: AudibleSyncState = {
  syncStatus: 'disconnected',
}

const updateSyncState = async (patch: Partial<AudibleSyncState>) => {
  const current = (await repository.findSyncState()) ?? DEFAULT_SYNC_STATE
  await repository.saveSyncState({ ...current, ...patch })
}

export namespace AudibleCommand {
  export const saveCredentials = async (credentials: AudibleCredentials) => {
    await repository.saveCredentials(credentials)
  }

  export const updateAccessToken = async (accessToken: string, expiresAt: Date) => {
    const existing = await repository.findCredentials()
    if (!existing) return 'no-credentials' as const
    await repository.saveCredentials({ ...existing, accessToken, expiresAt })
    return undefined
  }

  export const removeCredentials = async () => {
    await repository.removeCredentials()
  }

  export const saveMapping = async (mapping: AsinBookMapping) => {
    await repository.saveMapping(mapping)
  }

  export const saveRawItem = async (asin: Asin, entry: RawAudibleEntry) => {
    await repository.saveRawItem(asin, entry)
  }

  export const clearRawItems = async () => {
    await repository.clearRawItems()
  }

  export const clearMappings = async () => {
    await repository.clearMappings()
  }

  export const saveAuthSession = async (sessionId: string, session: AuthSession) => {
    await repository.saveAuthSession(sessionId, session)
  }

  export const consumeAuthSession = async (sessionId: string) => {
    const session = await repository.findAuthSession(sessionId)
    if (!session) return 'not-found' as const
    await repository.removeAuthSession(sessionId)
    return session
  }

  export const connect = async () => {
    await updateSyncState({ syncStatus: 'connected', syncUpdatedAt: new Date() })
  }

  export const startFetch = async () => {
    await updateSyncState({ syncStatus: 'fetching', syncUpdatedAt: new Date() })
  }

  export const completeFetch = async () => {
    await updateSyncState({ syncStatus: 'fetched', syncUpdatedAt: new Date() })
  }

  export const disconnect = async () => {
    await updateSyncState({
      syncStatus: 'disconnected',
      syncUpdatedAt: new Date(),
    })
  }
}
