import { keyBy } from 'lodash-es'
import * as repository from '~/domain/provider/audible/infrastructure/repository'
import type { Asin, AudibleSyncState, RawAudibleEntry } from '~/domain/provider/audible/types'

const DEFAULT_SYNC_STATE: AudibleSyncState = {
  syncStatus: 'disconnected',
  importStatus: 'init',
}

export type AudibleLibraryEntry = RawAudibleEntry & { importedBookId?: string }

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

  export const getLibrary = async (source?: 'library' | 'wishlist') => {
    const rawItems = await repository.findAllRawItems()
    const filtered = source ? rawItems.filter((entry) => entry.source === source) : rawItems
    const mappings = await repository.findAllMappings()
    const mappingsByAsin = keyBy(mappings, ({ asin }) => asin)

    return filtered.map((entry): AudibleLibraryEntry => {
      const mapping = mappingsByAsin[entry.item.asin]
      return mapping ? { ...entry, importedBookId: String(mapping.bookId) } : entry
    })
  }
}
