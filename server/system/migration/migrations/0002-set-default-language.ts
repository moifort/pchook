import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0002')

export const migration0002: Migration = {
  version: MigrationVersion(2),
  name: MigrationName('Set default language to fr'),
  migrate: async (ctx) => {
    const storage = ctx.storage('books')
    const keys = await storage.getKeys()
    let transformed = 0

    for (const key of keys) {
      const book = await storage.getItem<Record<string, unknown>>(key)
      if (book && !book.language) {
        book.language = 'fr'
        await storage.setItem(key, book)
        transformed++
      }
    }

    log.info(`Set language to fr for ${transformed}/${keys.length} books`)
    return { ok: true as const, transformed }
  },
}
