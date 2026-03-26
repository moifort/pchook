import { groupBy } from 'lodash-es'
import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0005')

const normalizeForMatch = (s: string) => s.toLowerCase().trim()

const coreTitle = (title: string) =>
  title
    .split(/[.:]/)[0]
    .trim()
    .replace(/[''""«»]/g, '')
    .replace(/\s+/g, ' ')

const groupingKey = (book: { title: string; authors: string[] }) => {
  const title = normalizeForMatch(coreTitle(book.title))
  const authors = book.authors.map(normalizeForMatch).sort().join('|')
  return `${title}::${authors}`
}

export const migration0005: Migration = {
  version: MigrationVersion(5),
  name: MigrationName('Deduplicate books keeping English version'),
  migrate: async (ctx) => {
    const booksStorage = ctx.storage('books')
    const mappingsStorage = ctx.storage('audible-mappings')

    const keys = await booksStorage.getKeys()
    const books = await Promise.all(
      keys.map(async (key) => {
        const book = await booksStorage.getItem<Record<string, unknown>>(key)
        return {
          id: key,
          title: book?.title as string,
          authors: (book?.authors ?? []) as string[],
          language: book?.language as string | undefined,
        }
      }),
    )

    const groups = groupBy(books, groupingKey)
    const replacements = new Map<string, string>()

    for (const group of Object.values(groups)) {
      if (group.length <= 1) continue
      const english = group.find((b) => b.language === 'en')
      if (!english) continue

      for (const book of group) {
        if (book.id === english.id) continue
        await booksStorage.removeItem(book.id)
        replacements.set(book.id, english.id)
        log.info(
          `Removed duplicate "${book.title}" (${book.language ?? 'unknown'}) — kept English version`,
        )
      }
    }

    if (replacements.size === 0) {
      log.info('No duplicates found')
      return { ok: true as const, transformed: 0 }
    }

    const mappingKeys = await mappingsStorage.getKeys()
    let updatedMappings = 0

    for (const key of mappingKeys) {
      const mapping = await mappingsStorage.getItem<Record<string, unknown>>(key)
      if (!mapping?.bookId) continue
      const englishId = replacements.get(mapping.bookId as string)
      if (!englishId) continue

      await mappingsStorage.setItem(key, { ...mapping, bookId: englishId })
      updatedMappings++
    }

    log.info(
      `Removed ${replacements.size} duplicate books, updated ${updatedMappings} Audible mappings`,
    )
    return { ok: true as const, transformed: replacements.size }
  },
}
