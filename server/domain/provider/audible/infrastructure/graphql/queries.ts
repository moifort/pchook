import { builder } from '~/domain/shared/graphql/builder'
import { AudibleType } from './types'

builder.queryField('audible', (t) =>
  t.field({
    type: AudibleType,
    description: 'Audible integration',
    resolve: () => ({}),
  }),
)
