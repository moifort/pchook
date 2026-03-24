import {
  buildGeminiPrompt,
  formatDuration,
  mergeAudibleIntoScanResult,
} from '~/domain/audible/business-rules'
import { AudibleCommand } from '~/domain/audible/command'
import {
  fetchLibrary,
  fetchWishlist,
  verifyConnection,
} from '~/domain/audible/infrastructure/audible.api'
import { AudibleQuery } from '~/domain/audible/query'
import type { AsinBookMapping, AudibleItem, RawAudibleEntry } from '~/domain/audible/types'
import { BookCommand } from '~/domain/book/command'
import type { Book } from '~/domain/book/types'
import { BookUseCase } from '~/domain/book/use-case'
import { callGemini } from '~/domain/scan/infrastructure/gemini'
import { enrichWithHardcover } from '~/domain/scan/scanner'
import { partialScanResultSchema } from '~/domain/scan/schemas'
import { scanResultToBookData } from '~/domain/scan/to-book-data'
import { SeriesCommand } from '~/domain/series/command'
import { SeriesLabel, SeriesPosition } from '~/domain/series/primitives'
import { SeriesQuery } from '~/domain/series/query'
import { PersonName, Url } from '~/domain/shared/primitives'
import { TaskId } from '~/domain/task/primitives'
import type { TaskDefinition } from '~/domain/task/types'
import { createLogger } from '~/system/logger'

const log = createLogger('audible-use-case')

const downloadCover = async (url: string) => {
  try {
    const arrayBuffer = await $fetch<ArrayBuffer>(url, { responseType: 'arrayBuffer' })
    return Buffer.from(arrayBuffer)
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
  const seriesNames = allSeries.map(({ name }) => name)
  const prompt = buildGeminiPrompt(item, seriesNames)
  const geminiResult = await callGemini(prompt)
  const geminiPartial = partialScanResultSchema.parse(geminiResult)
  const geminiScanResult = {
    ...geminiPartial,
    title: geminiPartial.title ?? item.title,
    authors: geminiPartial.authors ?? item.authors,
    awards: geminiPartial.awards,
    publicRatings: geminiPartial.publicRatings,
  }
  const { result: enrichedResult, coverImageBase64: hardcoverCoverBase64 } =
    await enrichWithHardcover(geminiScanResult)
  const scanResult = mergeAudibleIntoScanResult(enrichedResult, item)

  const { title, data, seriesInfo } = scanResultToBookData(scanResult)
  const isRead = source === 'library' && item.finishedAt !== undefined
  const status = isRead ? 'read' : 'to-read'
  const readDate = isRead ? item.finishedAt : undefined
  const audibleCover = item.coverUrl ? await downloadCover(item.coverUrl) : undefined
  const hardcoverCover = hardcoverCoverBase64
    ? Buffer.from(hardcoverCoverBase64, 'base64')
    : undefined
  const coverBuffer = audibleCover ?? hardcoverCover

  const externalUrl = Url(await buildAudibleUrl(String(item.asin)))
  const result = await BookUseCase.addFromScan(
    title,
    { ...data, status, readDate, importSource: 'audible', externalUrl },
    seriesInfo,
    coverBuffer,
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

export const AUDIBLE_IMPORT_TASK_ID = TaskId('00000000-0000-4000-a000-000000000001')

export const importTaskDefinition: TaskDefinition<RawAudibleEntry> = {
  items: () => AudibleQuery.getAllRawItems(),
  execute: async ({ item, source }) => {
    await importItem(item, source)
  },
  label: ({ item }) => `Import de "${item.title}"...`,
}

export namespace AudibleUseCase {
  export const verify = async () => {
    const credentials = await AudibleQuery.getCredentials()
    if (!credentials) return 'no-credentials' as const
    try {
      await verifyConnection(credentials)
      return 'ok' as const
    } catch {
      return 'invalid-credentials' as const
    }
  }

  export const fetchAndStore = async () => {
    const credentials = await AudibleQuery.getCredentials()
    if (!credentials) return 'no-credentials' as const
    if (AudibleQuery.isFetchInProgress()) return 'already-fetching' as const

    log.info('Starting Audible fetch')
    AudibleCommand.setFetchInProgress(true)

    try {
      const { items: libraryItems, credentials: afterLibrary } = await fetchLibrary(credentials)
      const { items: wishlistItems } = await fetchWishlist(afterLibrary)

      log.info('Fetched items', { library: libraryItems.length, wishlist: wishlistItems.length })

      await AudibleCommand.clearRawItems()

      const allEntries = [
        ...libraryItems.map((item) => ({ item, source: 'library' as const })),
        ...wishlistItems.map((item) => ({ item, source: 'wishlist' as const })),
      ]

      for (const { item, source } of allEntries) {
        await AudibleCommand.saveRawItem(item.asin, { item, source, downloadedAt: new Date() })
      }

      await AudibleCommand.saveLastFetchedAt(new Date())

      const listenedTotal = libraryItems.filter(({ finishedAt }) => finishedAt !== undefined).length
      const summary = {
        libraryTotal: libraryItems.length,
        listenedTotal,
        wishlistTotal: wishlistItems.length,
      }
      log.info('Fetch completed', summary)
      return summary
    } finally {
      AudibleCommand.setFetchInProgress(false)
    }
  }
}
