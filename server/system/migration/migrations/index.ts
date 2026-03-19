import { migration0001 } from '~/system/migration/migrations/0001-init'
import { migration0002 } from '~/system/migration/migrations/0002-merge-duplicate-series'
import { migration0003 } from '~/system/migration/migrations/0003-round-voter-count'
import { migration0004 } from '~/system/migration/migrations/0004-normalize-narrators-arrays'
import type { Migration } from '~/system/migration/types'

export const migrations: Migration[] = [migration0001, migration0002, migration0003, migration0004]
