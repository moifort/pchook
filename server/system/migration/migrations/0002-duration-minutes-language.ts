import { parseDuration } from '~/domain/shared/primitives'
import { createLogger } from '~/system/logger'
import { MigrationName, MigrationVersion } from '~/system/migration/primitives'
import type { Migration } from '~/system/migration/types'

const log = createLogger('migration:0002')

const languageMapping: Record<string, string> = {
  french: 'fr',
  français: 'fr',
  francais: 'fr',
  english: 'en',
  anglais: 'en',
  spanish: 'es',
  espagnol: 'es',
  german: 'de',
  allemand: 'de',
  italian: 'it',
  italien: 'it',
  portuguese: 'pt',
  portugais: 'pt',
  japanese: 'ja',
  japonais: 'ja',
  chinese: 'zh',
  chinois: 'zh',
  korean: 'ko',
  coréen: 'ko',
  russian: 'ru',
  russe: 'ru',
  dutch: 'nl',
  néerlandais: 'nl',
  polish: 'pl',
  polonais: 'pl',
  swedish: 'sv',
  suédois: 'sv',
  arabic: 'ar',
  arabe: 'ar',
}

const normalizeLanguage = (value: string) => {
  const lower = value.toLowerCase().trim()
  if (lower.length === 2) return lower
  return languageMapping[lower] ?? lower
}

export const migration0002: Migration = {
  version: MigrationVersion(2),
  name: MigrationName('Convert duration to minutes, normalize language codes'),
  migrate: async (ctx) => {
    const storage = ctx.storage('books')
    const keys = await storage.getKeys()
    let transformed = 0

    for (const key of keys) {
      const book = (await storage.getItem(key)) as Record<string, unknown> | null
      if (!book) continue

      let changed = false

      if (typeof book.duration === 'string') {
        const minutes = parseDuration(book.duration)
        if (minutes) {
          book.durationMinutes = minutes
          log.info('Converted duration', { key, from: book.duration, to: minutes })
        }
        delete book.duration
        changed = true
      }

      if (typeof book.language === 'string') {
        const normalized = normalizeLanguage(book.language)
        if (normalized !== book.language) {
          log.info('Normalized language', { key, from: book.language, to: normalized })
          book.language = normalized
          changed = true
        }
      }

      if (changed) {
        await storage.setItem(key, book)
        transformed++
      }
    }

    return { ok: true, transformed }
  },
}
