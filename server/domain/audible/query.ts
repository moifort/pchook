import * as repository from '~/domain/audible/repository'
import type { Asin } from '~/domain/audible/types'

export namespace AudibleQuery {
  export const hasCredentials = async () => {
    const credentials = await repository.findCredentials()
    return credentials !== null
  }

  export const getCredentials = async () => repository.findCredentials()

  export const getMapping = async (asin: Asin) => repository.findMapping(asin)

  export const getAllMappings = async () => repository.findAllMappings()

  export const getSyncProgress = () => repository.getSyncProgress()

  export const getSyncCompletedAt = async () => repository.findSyncCompletedAt()

  export const getAllRawItems = async () => repository.findAllRawItems()
}
