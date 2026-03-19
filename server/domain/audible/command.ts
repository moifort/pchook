import * as repository from '~/domain/audible/repository'
import type {
  Asin,
  AsinBookMapping,
  AudibleCredentials,
  AuthSession,
  RawAudibleEntry,
  SyncProgress,
} from '~/domain/audible/types'

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

  export const setSyncProgress = (progress: SyncProgress) => {
    repository.setSyncProgress(progress)
  }

  export const saveMapping = async (mapping: AsinBookMapping) => {
    await repository.saveMapping(mapping)
  }

  export const saveSyncCompletedAt = async (date: Date) => {
    await repository.saveSyncCompletedAt(date)
  }

  export const saveRawItem = async (asin: Asin, entry: RawAudibleEntry) => {
    await repository.saveRawItem(asin, entry)
  }

  export const clearRawItems = async () => {
    await repository.clearRawItems()
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
}
