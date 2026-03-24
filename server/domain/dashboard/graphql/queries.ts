import { DashboardReadModel } from '~/domain/dashboard/read-model'
import { builder } from '~/domain/shared/graphql/builder'
import { DashboardViewType } from './types'

builder.queryField('dashboard', (t) =>
  t.field({
    type: DashboardViewType,
    description: 'Tableau de bord avec statistiques de lecture',
    resolve: () => DashboardReadModel.get(),
  }),
)
