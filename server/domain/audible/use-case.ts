import { fetchLibrary, fetchWishlist } from '~/domain/audible/audible.api'
import { audibleItemToBookData } from '~/domain/audible/business-rules'
import { AudibleCommand } from '~/domain/audible/command'
import { AudibleQuery } from '~/domain/audible/query'
import type { AsinBookMapping, AudibleItem } from '~/domain/audible/types'
import { BookCommand } from '~/domain/book/command'
import { Genre, ISBN, Language, Note, PageCount, Publisher } from '~/domain/book/primitives'
import type { Award, Book, PublicRating } from '~/domain/book/types'
import { BookUseCase } from '~/domain/book/use-case'
import { Eur, PersonName } from '~/domain/shared/primitives'
import { createLogger } from '~/system/logger'
import { buildBookJsonSchema, callGemini, normalizeBookFormat } from '~/system/scan/gemini'

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

const enrichInBackground = async (book: Book) => {
  try {
    const authorsStr = book.authors.map(String).join(', ')
    const prompt = `Recherche le livre "${String(book.title)}" de ${authorsStr}.
Retourne toutes les informations au format JSON strict (sans markdown, sans backticks) :
${buildBookJsonSchema(false)}
Toutes les valeurs textuelles en français.`

    const parsed = await callGemini(prompt)

    const updates: Partial<Book> = {}
    if (!book.genre && parsed.genre) updates.genre = Genre(parsed.genre as string)
    if (!book.synopsis && parsed.synopsis) updates.synopsis = parsed.synopsis as string
    if (!book.isbn && parsed.isbn) updates.isbn = ISBN(parsed.isbn as string)
    if (!book.pageCount && parsed.pageCount) updates.pageCount = PageCount(parsed.pageCount)
    if (!book.publisher && parsed.publisher)
      updates.publisher = Publisher(parsed.publisher as string)
    if (!book.language && parsed.language) updates.language = Language(parsed.language as string)
    if (!book.translator && parsed.translator)
      updates.translator = PersonName(parsed.translator as string)
    if (!book.estimatedPrice && parsed.estimatedPrice)
      updates.estimatedPrice = Eur(parsed.estimatedPrice)
    if (book.awards.length === 0 && Array.isArray(parsed.awards) && parsed.awards.length > 0)
      updates.awards = parsed.awards as Award[]
    if (
      book.publicRatings.length === 0 &&
      Array.isArray(parsed.publicRatings) &&
      parsed.publicRatings.length > 0
    ) {
      updates.publicRatings = (parsed.publicRatings as PublicRating[]).map((r) => ({
        source: r.source,
        score: Note(r.score),
        maxScore: Note(r.maxScore),
        voterCount: r.voterCount,
      }))
    }
    if (!book.format && parsed.format) {
      const format = normalizeBookFormat(parsed.format as string)
      if (format) updates.format = format
    }

    if (Object.keys(updates).length > 0) {
      await BookCommand.update(book.id, updates)
      log.info('Book enriched', { id: book.id, fields: Object.keys(updates) })
    }
  } catch (error) {
    log.error('Enrichment failed', { id: book.id, error: String(error) })
  }
}

const mergeAudibleDataIntoDuplicate = async (book: Book, data: Partial<Book>) => {
  const updates: Partial<Book> = {}
  if (!book.format) updates.format = 'audiobook'
  if (!book.duration && data.duration) updates.duration = data.duration
  if ((!book.narrators || book.narrators.length === 0) && data.narrators?.length)
    updates.narrators = data.narrators
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

  const { title, data, seriesInfo, coverUrl } = audibleItemToBookData(item, source)
  const coverBase64 = coverUrl ? await downloadCover(coverUrl) : undefined

  const result = await BookUseCase.addFromScan(title, data, seriesInfo, coverBase64)

  if (result.tag === 'duplicate') {
    await mergeAudibleDataIntoDuplicate(result.book, data)
  }

  if (result.tag === 'created') {
    void enrichInBackground(result.book)
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
