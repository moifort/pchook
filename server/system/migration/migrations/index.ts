import { migration0001 } from '~/system/migration/migrations/0001-init'
import { migration0002 } from '~/system/migration/migrations/0002-set-default-language'
import { migration0003 } from '~/system/migration/migrations/0003-clean-stale-audible-mappings'
import { migration0004 } from '~/system/migration/migrations/0004-reset-audible-mappings'
import { migration0005 } from '~/system/migration/migrations/0005-deduplicate-keep-english'
import { migration0006 } from '~/system/migration/migrations/0006-clean-orphaned-series-books'
import type { Migration } from '~/system/migration/types'

export const migrations: Migration[] = [
  migration0001,
  migration0002,
  migration0003,
  migration0004,
  migration0005,
  migration0006,
]
