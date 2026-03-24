import { DashboardReadModel } from '~/domain/dashboard/read-model'

export default defineEventHandler(async () => {
  const dashboard = await DashboardReadModel.get()
  return { status: 200, data: dashboard } as const
})
