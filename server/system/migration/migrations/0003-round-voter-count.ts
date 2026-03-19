import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0003')

export const migration0003: Migration = {
  version: MigrationVersion(3),
  name: MigrationName('Round float voterCount in publicRatings'),
  migrate: async (ctx) => {
    const booksStorage = ctx.storage('books')
    const bookKeys = await booksStorage.getKeys()
    const bookItems = await booksStorage.getItems<Record<string, unknown>>(bookKeys)
    let fixed = 0

    for (const { key, value: book } of bookItems) {
      const ratings = book.publicRatings as
        | { source: string; score: number; maxScore: number; voterCount: number }[]
        | undefined
      if (!Array.isArray(ratings)) continue

      const hasFloat = ratings.some(({ voterCount }) => !Number.isInteger(voterCount))
      if (!hasFloat) continue

      const rounded = ratings.map((r) => ({ ...r, voterCount: Math.round(r.voterCount) }))
      await booksStorage.setItem(key, { ...book, publicRatings: rounded })
      fixed++
    }

    if (fixed > 0) {
      log.info(`Rounded voterCount in ${fixed} books`)
    }

    return { ok: true, transformed: fixed }
  },
}
