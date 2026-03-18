import { AudibleCommand } from '~/domain/audible/command'

export default defineEventHandler(async () => {
  await AudibleCommand.removeCredentials()
  return { status: 200, data: { success: true } } as const
})
