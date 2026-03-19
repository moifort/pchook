import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0004')

type BookEntry = { id: string; narrators?: unknown[] }

export const migration0004: Migration = {
  version: MigrationVersion(4),
  name: MigrationName('Normalize narrators arrays'),
  migrate: async (ctx) => {
    const booksStorage = ctx.storage('books')
    const keys = await booksStorage.getKeys()
    const items = await booksStorage.getItems<BookEntry>(keys)

    let transformed = 0

    for (const { key, value: book } of items) {
      if (!Array.isArray(book.narrators)) {
        await booksStorage.setItem(key, { ...book, narrators: [] })
        transformed += 1
        log.info('Normalized narrators for book', { id: book.id })
      }
    }

    log.info('Migration complete', { total: items.length, transformed })
    return { ok: true, transformed } as const
  },
}
