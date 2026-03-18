import { fetchLibrary, fetchWishlist } from '~/domain/audible/audible.api'
import {
  buildGeminiPrompt,
  formatDuration,
  mergeAudibleIntoScanResult,
} from '~/domain/audible/business-rules'
import { AudibleCommand } from '~/domain/audible/command'
import { AudibleQuery } from '~/domain/audible/query'
import type { AsinBookMapping, AudibleItem } from '~/domain/audible/types'
import { BookCommand } from '~/domain/book/command'
import type { Book } from '~/domain/book/types'
import { BookUseCase } from '~/domain/book/use-case'
import { PersonName } from '~/domain/shared/primitives'
import { createLogger } from '~/system/logger'
import { callGemini } from '~/system/scan/gemini'
import { scanResultToBookData } from '~/system/scan/to-book-data'

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

const mergeAudibleDataIntoDuplicate = async (book: Book, item: AudibleItem) => {
  const updates: Partial<Book> = {}
  if (!book.format) updates.format = 'audiobook'
  if (!book.duration && item.durationMinutes > 0) {
    updates.duration = formatDuration(item.durationMinutes)
  }
  if ((!book.narrators || book.narrators.length === 0) && item.narrators.length > 0) {
    updates.narrators = item.narrators.map((name) => PersonName(name))
  }
  if (Object.keys(updates).length > 0) {
    await BookCommand.update(book.id, updates)
    log.info('Duplicate book merged with Audible data', {
      id: book.id,
      fields: Object.keys(updates),
    })
  }
}

const syncItem = async (item: AudibleItem, source: 'library' | 'wishlist') => {
  log.info('Audible item', {
    asin: item.asin,
    title: item.title,
    authors: item.authors,
    narrators: item.narrators,
    durationMinutes: item.durationMinutes,
    publisher: item.publisher,
    language: item.language,
    series: item.series,
    source,
  })

  const existingMapping = await AudibleQuery.getMapping(item.asin)
  if (existingMapping) return 'skipped' as const

  const prompt = buildGeminiPrompt(item)
  const geminiResult = await callGemini(prompt)
  const scanResult = mergeAudibleIntoScanResult(geminiResult, item)

  const { title, data, seriesInfo } = scanResultToBookData(scanResult)
  const status = source === 'library' ? 'read' : 'to-read'
  const coverBase64 = item.coverUrl ? await downloadCover(item.coverUrl) : undefined

  const result = await BookUseCase.addFromScan(title, { ...data, status }, seriesInfo, coverBase64)

  if (result.tag === 'duplicate') {
    await mergeAudibleDataIntoDuplicate(result.book, item)
  }

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
    AudibleCommand.setSyncProgress({
      phase: 'fetching',
      current: 0,
      total: 0,
      message: 'Récupération de la bibliothèque...',
    })

    const { items: libraryItems, credentials: afterLibrary } = await fetchLibrary(credentials)
    AudibleCommand.setSyncProgress({
      phase: 'fetching',
      current: 0,
      total: 0,
      message: 'Récupération de la liste de souhaits...',
    })

    const { items: wishlistItems } = await fetchWishlist(afterLibrary)

    log.info('Fetched items', {
      library: libraryItems.length,
      wishlist: wishlistItems.length,
    })

    const allItems = [
      ...libraryItems.map((item) => ({ item, source: 'library' as const })),
      ...wishlistItems.map((item) => ({ item, source: 'wishlist' as const })),
    ]
    const total = allItems.length
    let newBooksAdded = 0
    let duplicatesSkipped = 0

    for (const [index, { item, source }] of allItems.entries()) {
      AudibleCommand.setSyncProgress({
        phase: 'syncing',
        current: index + 1,
        total,
        message: `Import de "${item.title}"...`,
      })

      const result = await syncItem(item, source)
      if (result === 'created') newBooksAdded += 1
      else duplicatesSkipped += 1
    }

    AudibleCommand.setSyncProgress({
      phase: 'done',
      current: total,
      total,
      message: `${newBooksAdded} livres ajoutés, ${duplicatesSkipped} doublons`,
    })

    log.info('Sync completed', { newBooksAdded, duplicatesSkipped })

    return {
      libraryCount: libraryItems.length,
      wishlistCount: wishlistItems.length,
      newBooksAdded,
      duplicatesSkipped,
    } as const
  }
}
