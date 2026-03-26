import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0006')

export const migration0006: Migration = {
  version: MigrationVersion(6),
  name: MigrationName('Clean orphaned series-book entries'),
  migrate: async (ctx) => {
    const seriesBooks = ctx.storage('series-books')
    const books = ctx.storage('books')
    const keys = await seriesBooks.getKeys()
    let transformed = 0

    for (const key of keys) {
      const bookId = key.split(':')[1]
      if (!bookId) continue
      const bookExists = await books.hasItem(bookId)
      if (!bookExists) {
        await seriesBooks.removeItem(key)
        transformed++
        log.info(`Removed orphaned series-book entry ${key}`)
      }
    }

    log.info(`Removed ${transformed}/${keys.length} orphaned series-book entries`)
    return { ok: true as const, transformed }
  },
}
