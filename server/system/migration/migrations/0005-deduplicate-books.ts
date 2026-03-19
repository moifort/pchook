import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0005')

type BookEntry = {
  id: string
  title: string
  authors: string[]
  isbn?: string
  genre?: string
  synopsis?: string
  publisher?: string
  language?: string
  format?: string
  translator?: string
  estimatedPrice?: number
  pageCount?: number
  duration?: string
  narrators?: string[]
  awards?: unknown[]
  publicRatings?: unknown[]
  publishedDate?: string
  createdAt: string
  [key: string]: unknown
}

type MappingEntry = { asin: string; bookId: string; source: string; syncedAt: string }
type SeriesBookEntry = { seriesId: string; bookId: string; position: number; addedAt: string }
type ReviewEntry = { bookId: string; rating: number; readDate?: string; createdAt: string }

const normalizeTitle = (title: string) =>
  title
    .toLowerCase()
    .trim()
    .split(/[.:]/)[0]
    .trim()
    .replace(/[''""«»]/g, '')
    .replace(/\s+/g, ' ')

const normalizeAuthor = (author: string) => author.toLowerCase().trim()

const groupDuplicates = (books: BookEntry[]) => {
  const groups = new Map<string, BookEntry[]>()

  // Pass 1: group by ISBN
  const byIsbn = new Map<string, BookEntry[]>()
  const withoutIsbn: BookEntry[] = []

  for (const book of books) {
    if (book.isbn) {
      const key = book.isbn.replace(/[-\s]/g, '').toLowerCase()
      const group = byIsbn.get(key) ?? []
      group.push(book)
      byIsbn.set(key, group)
    } else {
      withoutIsbn.push(book)
    }
  }

  for (const [isbn, group] of byIsbn) {
    if (group.length > 1) {
      groups.set(`isbn:${isbn}`, group)
    }
  }

  // Pass 2: group remaining by normalized title + authors
  const assigned = new Set(
    [...groups.values()].flatMap((group) => group.slice(1).map(({ id }) => id)),
  )

  const allForTitleMatch = [...books.filter(({ id }) => !assigned.has(id))]
  const byTitleAuthor = new Map<string, BookEntry[]>()

  for (const book of allForTitleMatch) {
    const authors = book.authors.map(normalizeAuthor).sort().join(',')
    const key = `${normalizeTitle(book.title)}|${authors}`
    const group = byTitleAuthor.get(key) ?? []
    group.push(book)
    byTitleAuthor.set(key, group)
  }

  for (const [key, group] of byTitleAuthor) {
    if (group.length > 1) {
      groups.set(`title:${key}`, group)
    }
  }

  return groups
}

const mergeFields = (canonical: BookEntry, duplicate: BookEntry) => {
  const merged: Record<string, unknown> = {}
  const fieldsToMerge = [
    'isbn',
    'genre',
    'synopsis',
    'publisher',
    'language',
    'format',
    'translator',
    'estimatedPrice',
    'pageCount',
    'duration',
    'publishedDate',
  ] as const

  for (const field of fieldsToMerge) {
    if (!canonical[field] && duplicate[field]) {
      merged[field] = duplicate[field]
    }
  }

  if ((!canonical.narrators || canonical.narrators.length === 0) && duplicate.narrators?.length) {
    merged.narrators = duplicate.narrators
  }

  if ((!canonical.awards || canonical.awards.length === 0) && duplicate.awards?.length) {
    merged.awards = duplicate.awards
  }

  if (
    (!canonical.publicRatings || canonical.publicRatings.length === 0) &&
    duplicate.publicRatings?.length
  ) {
    merged.publicRatings = duplicate.publicRatings
  }

  return merged
}

export const migration0005: Migration = {
  version: MigrationVersion(5),
  name: MigrationName('Deduplicate books'),
  migrate: async (ctx) => {
    const booksStorage = ctx.storage('books')
    const imagesStorage = ctx.storage('book-images')
    const mappingsStorage = ctx.storage('audible-mappings')
    const seriesBooksStorage = ctx.storage('series-books')
    const reviewsStorage = ctx.storage('reviews')

    // Load all data
    const bookKeys = await booksStorage.getKeys()
    const bookItems = await booksStorage.getItems<BookEntry>(bookKeys)
    const allBooks = bookItems.map(({ value }) => value)

    const mappingKeys = await mappingsStorage.getKeys()
    const mappingItems = await mappingsStorage.getItems<MappingEntry>(mappingKeys)
    const allMappings = mappingItems.map(({ value }) => value)

    const seriesBooksKeys = await seriesBooksStorage.getKeys()
    const seriesBooksItems = await seriesBooksStorage.getItems<SeriesBookEntry>(seriesBooksKeys)
    const allSeriesBooks = seriesBooksItems.map(({ value }) => value)

    const groups = groupDuplicates(allBooks)
    let transformed = 0

    for (const [reason, group] of groups) {
      const sorted = group.sort(
        (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
      )
      const canonical = sorted[0]
      const duplicates = sorted.slice(1)

      log.info(
        `Dedup [${reason}]: keeping "${canonical.title}" (${canonical.id}), removing ${duplicates.length} duplicate(s)`,
      )

      for (const duplicate of duplicates) {
        // 1. Merge missing fields into canonical
        const merged = mergeFields(canonical, duplicate)
        if (Object.keys(merged).length > 0) {
          const current = await booksStorage.getItem<BookEntry>(canonical.id)
          if (current) {
            await booksStorage.setItem(canonical.id, { ...current, ...merged })
            log.info(`  Merged fields [${Object.keys(merged).join(', ')}] into canonical`)
          }
        }

        // 2. Reassign audible mappings
        const bookMappings = allMappings.filter(({ bookId }) => bookId === duplicate.id)
        for (const mapping of bookMappings) {
          await mappingsStorage.setItem(mapping.asin, { ...mapping, bookId: canonical.id })
          log.info(`  Reassigned mapping ${mapping.asin} to canonical`)
        }

        // 3. Reassign series-books
        const seriesEntries = allSeriesBooks.filter(({ bookId }) => bookId === duplicate.id)
        for (const entry of seriesEntries) {
          const alreadyLinked = allSeriesBooks.some(
            (sb) => sb.seriesId === entry.seriesId && sb.bookId === canonical.id,
          )
          if (!alreadyLinked) {
            const newEntry = { ...entry, bookId: canonical.id }
            await seriesBooksStorage.setItem(`${entry.seriesId}:${canonical.id}`, newEntry)
            log.info(`  Moved series-book to canonical (series ${entry.seriesId})`)
          }
          await seriesBooksStorage.removeItem(`${entry.seriesId}:${duplicate.id}`)
        }

        // 4. Handle reviews — keep canonical's, delete duplicate's
        const duplicateReview = await reviewsStorage.getItem<ReviewEntry>(`entries:${duplicate.id}`)
        if (duplicateReview) {
          const canonicalReview = await reviewsStorage.getItem<ReviewEntry>(
            `entries:${canonical.id}`,
          )
          if (!canonicalReview) {
            await reviewsStorage.setItem(`entries:${canonical.id}`, {
              ...duplicateReview,
              bookId: canonical.id,
            })
            log.info(`  Moved review to canonical`)
          }
          await reviewsStorage.removeItem(`entries:${duplicate.id}`)
        }

        // 5. Handle images — take duplicate's if canonical has none
        const canonicalImage = await imagesStorage.getItem(canonical.id)
        if (!canonicalImage) {
          const duplicateImage = await imagesStorage.getItem(duplicate.id)
          if (duplicateImage) {
            await imagesStorage.setItem(canonical.id, duplicateImage)
            log.info(`  Moved cover image to canonical`)
          }
        }
        await imagesStorage.removeItem(duplicate.id)

        // 6. Delete duplicate book
        await booksStorage.removeItem(duplicate.id)
        transformed++
        log.info(`  Removed duplicate "${duplicate.title}" (${duplicate.id})`)
      }
    }

    log.info(`Deduplicated ${transformed} books`)

    // --- Phase 2: Merge duplicate series by name ---
    const seriesStorage = ctx.storage('series')
    type SeriesEntry = { id: string; name: string; createdAt: string }

    const seriesKeys = await seriesStorage.getKeys()
    const seriesItems = await seriesStorage.getItems<SeriesEntry>(seriesKeys)
    const allSeriesList = seriesItems.map(({ value }) => value)

    const byName = new Map<string, SeriesEntry[]>()
    for (const series of allSeriesList) {
      const key = series.name.toLowerCase().trim()
      const group = byName.get(key) ?? []
      group.push(series)
      byName.set(key, group)
    }

    // Reload series-books after book dedup
    const sbKeys2 = await seriesBooksStorage.getKeys()
    const sbItems2 = await seriesBooksStorage.getItems<SeriesBookEntry>(sbKeys2)
    const allSB2 = sbItems2.map(({ value }) => value)

    let mergedSeries = 0
    for (const [, group] of byName) {
      if (group.length <= 1) continue

      const sorted = group.sort(
        (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
      )
      const canonical = sorted[0]
      const duplicates = sorted.slice(1)

      log.info(
        `Merging ${duplicates.length} duplicate series "${canonical.name}" into ${canonical.id}`,
      )

      for (const dup of duplicates) {
        const entries = allSB2.filter(({ seriesId }) => seriesId === dup.id)
        for (const entry of entries) {
          const alreadyLinked = allSB2.some(
            (sb) => sb.seriesId === canonical.id && sb.bookId === entry.bookId,
          )
          if (!alreadyLinked) {
            await seriesBooksStorage.setItem(`${canonical.id}:${entry.bookId}`, {
              ...entry,
              seriesId: canonical.id,
            })
          }
          await seriesBooksStorage.removeItem(`${dup.id}:${entry.bookId}`)
        }
        await seriesStorage.removeItem(dup.id)
        mergedSeries++
      }
    }

    if (mergedSeries > 0) {
      log.info(`Merged ${mergedSeries} duplicate series`)
    }

    // --- Phase 3: Ensure each book belongs to at most one series ---
    const sbKeys3 = await seriesBooksStorage.getKeys()
    const sbItems3 = await seriesBooksStorage.getItems<SeriesBookEntry>(sbKeys3)
    const allSB3 = sbItems3.map(({ value, key }) => ({ ...value, _key: key }))

    const byBookId = new Map<string, (SeriesBookEntry & { _key: string })[]>()
    for (const entry of allSB3) {
      const group = byBookId.get(entry.bookId) ?? []
      group.push(entry)
      byBookId.set(entry.bookId, group)
    }

    let removedDupLinks = 0
    for (const [bookId, entries] of byBookId) {
      if (entries.length <= 1) continue

      // Keep the first (oldest addedAt), remove the rest
      const sorted = entries.sort(
        (a, b) => new Date(a.addedAt).getTime() - new Date(b.addedAt).getTime(),
      )
      const keep = sorted[0]
      const remove = sorted.slice(1)

      for (const entry of remove) {
        await seriesBooksStorage.removeItem(entry._key)
        removedDupLinks++
        log.info(
          `Removed duplicate series-book link for book ${bookId} (was in series ${entry.seriesId}, keeping ${keep.seriesId})`,
        )
      }
    }

    if (removedDupLinks > 0) {
      log.info(`Removed ${removedDupLinks} duplicate series-book links`)
    }

    return { ok: true, transformed: transformed + mergedSeries + removedDupLinks }
  },
}
