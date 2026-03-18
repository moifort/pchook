import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0002')

type SeriesEntry = { id: string; name: string; createdAt: string }
type SeriesBookEntry = { seriesId: string; bookId: string; position: number; addedAt: string }

export const migration0002: Migration = {
  version: MigrationVersion(2),
  name: MigrationName('Merge duplicate series'),
  migrate: async (ctx) => {
    const seriesStorage = ctx.storage('series')
    const seriesBooksStorage = ctx.storage('series-books')

    const seriesKeys = await seriesStorage.getKeys()
    const seriesItems = await seriesStorage.getItems<SeriesEntry>(seriesKeys)
    const allSeries = seriesItems.map(({ value }) => value)

    // Group series by lowercase name
    const byName = new Map<string, SeriesEntry[]>()
    for (const series of allSeries) {
      const key = series.name.toLowerCase()
      const group = byName.get(key) ?? []
      group.push(series)
      byName.set(key, group)
    }

    const seriesBooksKeys = await seriesBooksStorage.getKeys()
    const seriesBooksItems = await seriesBooksStorage.getItems<SeriesBookEntry>(seriesBooksKeys)
    const allSeriesBooks = seriesBooksItems.map(({ value }) => value)

    let transformed = 0

    for (const [name, group] of byName) {
      if (group.length <= 1) continue

      // Keep the oldest series as canonical
      const sorted = group.sort(
        (a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
      )
      const canonical = sorted[0]
      const duplicates = sorted.slice(1)

      log.info(`Merging ${duplicates.length} duplicate(s) for "${name}" into ${canonical.id}`)

      for (const duplicate of duplicates) {
        // Find all series-book entries for this duplicate
        const entries = allSeriesBooks.filter((sb) => sb.seriesId === duplicate.id)

        for (const entry of entries) {
          // Check if this book is already in the canonical series
          const alreadyLinked = allSeriesBooks.some(
            (sb) => sb.seriesId === canonical.id && sb.bookId === entry.bookId,
          )

          if (!alreadyLinked) {
            // Move entry to canonical series
            const newEntry: SeriesBookEntry = {
              ...entry,
              seriesId: canonical.id,
            }
            await seriesBooksStorage.setItem(`${canonical.id}:${entry.bookId}`, newEntry)
            log.info(`Moved book ${entry.bookId} (position ${entry.position}) to canonical series`)
          }

          // Remove old entry
          await seriesBooksStorage.removeItem(`${duplicate.id}:${entry.bookId}`)
        }

        // Remove duplicate series
        await seriesStorage.removeItem(duplicate.id)
        transformed++
      }
    }

    log.info(`Merged ${transformed} duplicate series`)

    // Fix publicRatings with null voterCount
    const booksStorage = ctx.storage('books')
    const bookKeys = await booksStorage.getKeys()
    const bookItems = await booksStorage.getItems<Record<string, unknown>>(bookKeys)
    let fixedBooks = 0

    for (const { key, value: book } of bookItems) {
      const ratings = book.publicRatings as { voterCount?: number | null }[] | undefined
      if (!Array.isArray(ratings)) continue

      const hasNull = ratings.some((r) => r.voterCount == null)
      if (!hasNull) continue

      const fixed = ratings.filter((r) => r.voterCount != null)
      await booksStorage.setItem(key, { ...book, publicRatings: fixed })
      fixedBooks++
    }

    if (fixedBooks > 0) {
      log.info(`Fixed ${fixedBooks} books with null voterCount in publicRatings`)
    }

    return { ok: true, transformed: transformed + fixedBooks }
  },
}
