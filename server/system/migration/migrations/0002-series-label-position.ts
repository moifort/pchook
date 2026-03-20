import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0002')

export const migration0002: Migration = {
  version: MigrationVersion(2),
  name: MigrationName('Add label field to series-books'),
  migrate: async ({ storage }) => {
    const seriesBooks = storage('series-books')
    const keys = await seriesBooks.getKeys()

    let transformed = 0

    await Promise.all(
      keys.map(async (key) => {
        const entry = (await seriesBooks.getItem(key)) as Record<string, unknown> | null
        if (!entry) return

        if (entry.label) return

        entry.label = String(entry.position ?? 1)
        await seriesBooks.setItem(key, entry)
        transformed += 1
        log.info('Added label to series-book', { key, label: entry.label })
      }),
    )

    return { ok: true, transformed } as const
  },
}
