import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0004')

export const migration0004: Migration = {
  version: MigrationVersion(4),
  name: MigrationName('Reset Audible mappings after language-aware duplicate fix'),
  migrate: async (ctx) => {
    const mappings = ctx.storage('audible-mappings')
    const keys = await mappings.getKeys()

    for (const key of keys) {
      await mappings.removeItem(key)
    }

    log.info(`Cleared ${keys.length} Audible mappings for fresh re-import`)
    return { ok: true as const, transformed: keys.length }
  },
}
