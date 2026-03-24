import { DashboardReadModel } from '~/domain/dashboard/read-model'
import { builder } from '~/domain/shared/graphql/builder'
import { DashboardViewType } from './types'

builder.queryField('dashboard', (t) =>
  t.field({
    type: DashboardViewType,
    description: 'Dashboard with reading statistics',
    resolve: () => DashboardReadModel.get(),
  }),
)
