import { fetchLibrary, fetchWishlist, verifyConnection } from '~/domain/audible/audible.api'
import {
  buildGeminiPrompt,
  formatDuration,
  mergeAudibleIntoScanResult,
} from '~/domain/audible/business-rules'
import { AudibleCommand } from '~/domain/audible/command'
import { AudibleQuery } from '~/domain/audible/query'
import type {
  AsinBookMapping,
  AudibleItem,
  AudibleSummary,
  SyncPhase,
  SyncProgress,
} from '~/domain/audible/types'
import { BookCommand } from '~/domain/book/command'
import type { Book } from '~/domain/book/types'
import { BookUseCase } from '~/domain/book/use-case'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesPosition } from '~/domain/series/primitives'
import { SeriesQuery } from '~/domain/series/query'
import { PersonName, Url } from '~/domain/shared/primitives'
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
  if (book.narrators.length === 0 && item.narrators.length > 0) {
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

const buildAudibleUrl = async (asin: string) => {
  const credentials = await AudibleQuery.getCredentials()
  const locale = credentials?.locale ?? 'fr'
  return `https://www.audible.${locale}/pd/${asin}`
}

const importItem = async (item: AudibleItem, source: 'library' | 'wishlist') => {
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

  const allSeries = await SeriesQuery.findAll()
  const seriesNames = allSeries.map(({ name }) => String(name))
  const prompt = buildGeminiPrompt(item, seriesNames)
  const geminiResult = await callGemini(prompt)
  const scanResult = mergeAudibleIntoScanResult(geminiResult, item)

  const { title, data, seriesInfo } = scanResultToBookData(scanResult)
  const status = source === 'library' && item.isFinished === true ? 'read' : 'to-read'
  const coverBase64 = item.coverUrl ? await downloadCover(item.coverUrl) : undefined

  const externalUrl = Url(await buildAudibleUrl(String(item.asin)))
  const result = await BookUseCase.addFromScan(
    title,
    { ...data, status, importSource: 'audible', externalUrl },
    seriesInfo,
    coverBase64,
  )

  if (result.tag === 'duplicate') {
    await mergeAudibleDataIntoDuplicate(result.book, item)
    if (seriesInfo?.name) {
      const existingSeries = await SeriesQuery.getByBookId(result.book.id)
      if (!existingSeries) {
        const series = await SeriesCommand.findOrCreate(seriesInfo.name)
        const label = SeriesLabel(seriesInfo.label ?? String(seriesInfo.number ?? 1))
        const position = SeriesPosition(seriesInfo.number ?? 1)
        await SeriesCommand.addBook(series.id, result.book.id, label, position)
      }
    }
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

const checkSyncControl = async (currentPhase: SyncPhase, currentProgress: SyncProgress) => {
  if (AudibleQuery.isCancelRequested()) {
    log.info('Sync cancelled by user')
    return 'cancelled' as const
  }
  if (AudibleQuery.isPaused()) {
    AudibleCommand.setSyncProgress({ ...currentProgress, phase: 'paused' })
    log.info('Sync paused by user')
    await AudibleQuery.waitIfPaused()
    AudibleCommand.setSyncProgress({ ...currentProgress, phase: currentPhase })
    log.info('Sync resumed by user')
  }
  return 'continue' as const
}

export namespace AudibleUseCase {
  export const verify = async () => {
    const credentials = await AudibleQuery.getCredentials()
    if (!credentials) return 'no-credentials' as const

    const currentProgress = AudibleQuery.getSyncProgress()
    const ownProgress = currentProgress.phase === 'idle'

    try {
      if (ownProgress) {
        AudibleCommand.setSyncProgress({
          phase: 'verifying',
          current: 0,
          total: 0,
          message: 'Vérification de la connexion...',
        })
      }
      await verifyConnection(credentials)
      return 'ok' as const
    } catch {
      return 'invalid-credentials' as const
    } finally {
      if (ownProgress) {
        AudibleCommand.setSyncProgress({ phase: 'idle', current: 0, total: 0, message: '' })
      }
    }
  }

  export const fetchAndStore = async () => {
    const credentials = await AudibleQuery.getCredentials()
    if (!credentials) return 'no-credentials' as const

    log.info('Starting Audible fetch')

    try {
      AudibleCommand.setSyncProgress({
        phase: 'downloading',
        current: 0,
        total: 0,
        message: 'Récupération de la bibliothèque...',
      })

      const { items: libraryItems, credentials: afterLibrary } = await fetchLibrary(credentials)

      AudibleCommand.setSyncProgress({
        phase: 'downloading',
        current: 0,
        total: 0,
        message: 'Récupération de la liste de souhaits...',
      })

      const { items: wishlistItems } = await fetchWishlist(afterLibrary)

      log.info('Fetched items', {
        library: libraryItems.length,
        wishlist: wishlistItems.length,
      })

      await AudibleCommand.clearRawItems()

      const allEntries = [
        ...libraryItems.map((item) => ({ item, source: 'library' as const })),
        ...wishlistItems.map((item) => ({ item, source: 'wishlist' as const })),
      ]
      const total = allEntries.length

      for (const [index, { item, source }] of allEntries.entries()) {
        const progress = {
          phase: 'downloading' as const,
          current: index + 1,
          total,
          message: `Stockage de "${item.title}"...`,
        }
        const control = await checkSyncControl('downloading', progress)
        if (control === 'cancelled') break
        AudibleCommand.setSyncProgress(progress)
        await AudibleCommand.saveRawItem(item.asin, {
          item,
          source,
          downloadedAt: new Date(),
        })
      }

      const listenedTotal = libraryItems.filter(({ isFinished }) => isFinished === true).length

      const summary: AudibleSummary = {
        libraryTotal: libraryItems.length,
        listenedTotal,
        wishlistTotal: wishlistItems.length,
      }

      log.info('Fetch completed', summary)

      return summary
    } finally {
      AudibleCommand.clearCancel()
      AudibleCommand.setSyncProgress({ phase: 'idle', current: 0, total: 0, message: '' })
    }
  }

  export const importAll = async () => {
    const rawItems = await AudibleQuery.getAllRawItems()
    if (rawItems.length === 0) return 'no-data' as const

    log.info('Starting import', { total: rawItems.length })

    try {
      const total = rawItems.length
      let newBooksAdded = 0
      let duplicatesSkipped = 0
      let failed = 0

      for (const [index, { item, source }] of rawItems.entries()) {
        const progress = {
          phase: 'importing' as const,
          current: index + 1,
          total,
          message: `Import de "${item.title}"...`,
        }
        const control = await checkSyncControl('importing', progress)
        if (control === 'cancelled') break
        AudibleCommand.setSyncProgress(progress)

        try {
          const result = await importItem(item, source)
          if (result === 'created') newBooksAdded += 1
          else duplicatesSkipped += 1
        } catch (error) {
          failed += 1
          log.error('Failed to import item', {
            asin: item.asin,
            title: item.title,
            error: String(error),
          })
        }
      }

      await AudibleCommand.saveSyncCompletedAt(new Date())
      log.info('Import completed', { newBooksAdded, duplicatesSkipped, failed })

      return { newBooksAdded, duplicatesSkipped, failed } as const
    } finally {
      AudibleCommand.clearCancel()
      AudibleCommand.setSyncProgress({ phase: 'idle', current: 0, total: 0, message: '' })
    }
  }
}
