import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0003')

export const migration0003: Migration = {
  version: MigrationVersion(3),
  name: MigrationName('Clean stale Audible mappings'),
  migrate: async (ctx) => {
    const mappings = ctx.storage('audible-mappings')
    const books = ctx.storage('books')
    const keys = await mappings.getKeys()
    let transformed = 0

    for (const key of keys) {
      const mapping = await mappings.getItem<Record<string, unknown>>(key)
      if (!mapping?.bookId) continue
      const bookExists = await books.hasItem(mapping.bookId as string)
      if (!bookExists) {
        await mappings.removeItem(key)
        transformed++
      }
    }

    log.info(`Removed ${transformed}/${keys.length} stale Audible mappings`)
    return { ok: true as const, transformed }
  },
}
