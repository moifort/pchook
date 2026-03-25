import * as repository from '~/domain/provider/audible/infrastructure/repository'
import type { Asin, AudibleSyncState } from '~/domain/provider/audible/types'

const DEFAULT_SYNC_STATE: AudibleSyncState = {
  syncStatus: 'disconnected',
}

export namespace AudibleQuery {
  export const hasCredentials = async () => {
    const credentials = await repository.findCredentials()
    return credentials !== null
  }

  export const getCredentials = async () => repository.findCredentials()

  export const getMapping = async (asin: Asin) => repository.findMapping(asin)

  export const getAllMappings = async () => repository.findAllMappings()

  export const getAllRawItems = async () => repository.findAllRawItems()

  export const getSyncState = async () => {
    const state = await repository.findSyncState()
    return state ?? DEFAULT_SYNC_STATE
  }
}
