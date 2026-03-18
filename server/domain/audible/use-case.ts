import { fetchLibrary, fetchWishlist } from '~/domain/audible/audible.api'
import { audibleItemToBookData } from '~/domain/audible/business-rules'
import { AudibleCommand } from '~/domain/audible/command'
import { AudibleQuery } from '~/domain/audible/query'
import type { AsinBookMapping, AudibleItem } from '~/domain/audible/types'
import { BookUseCase } from '~/domain/book/use-case'
import { createLogger } from '~/system/logger'

const log = createLogger('audible-use-case')

const downloadCover = async (url: string) => {
  try {
    const buffer = await $fetch<ArrayBuffer>(url, { responseType: 'arrayBuffer' })
    return Buffer.from(buffer).toString('base64')
  } catch (error) {
    log.warn('Failed to download cover', { url, error: String(error) })
    return undefined
  }
}

const syncItem = async (item: AudibleItem, source: 'library' | 'wishlist') => {
  const existingMapping = await AudibleQuery.getMapping(item.asin)
  if (existingMapping) return 'skipped' as const

  const { title, data, seriesInfo, coverUrl } = audibleItemToBookData(item, source)
  const coverBase64 = coverUrl ? await downloadCover(coverUrl) : undefined

  const result = await BookUseCase.addFromScan(title, data, seriesInfo, coverBase64)

  const mapping: AsinBookMapping = {
    asin: item.asin,
    bookId: result.book.id,
    source,
    syncedAt: new Date(),
  }
  await AudibleCommand.saveMapping(mapping)

  return result.tag
}

export namespace AudibleUseCase {
  export const syncAll = async () => {
    const credentials = await AudibleQuery.getCredentials()
    if (!credentials) return 'no-credentials' as const

    log.info('Starting Audible sync')

    const { items: libraryItems, credentials: afterLibrary } = await fetchLibrary(credentials)
    const { items: wishlistItems } = await fetchWishlist(afterLibrary)

    log.info('Fetched items', {
      library: libraryItems.length,
      wishlist: wishlistItems.length,
    })

    let newBooksAdded = 0
    let duplicatesSkipped = 0

    for (const item of libraryItems) {
      const result = await syncItem(item, 'library')
      if (result === 'created') newBooksAdded += 1
      else duplicatesSkipped += 1
    }

    for (const item of wishlistItems) {
      const result = await syncItem(item, 'wishlist')
      if (result === 'created') newBooksAdded += 1
      else duplicatesSkipped += 1
    }

    log.info('Sync completed', { newBooksAdded, duplicatesSkipped })

    return {
      libraryCount: libraryItems.length,
      wishlistCount: wishlistItems.length,
      newBooksAdded,
      duplicatesSkipped,
    } as const
  }
}
