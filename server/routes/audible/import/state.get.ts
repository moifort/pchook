import { importRunner } from '~/domain/audible/use-case'

export default defineEventHandler(async () => {
  const state = await importRunner.getState()
  return { status: 200, data: state } as const
})
