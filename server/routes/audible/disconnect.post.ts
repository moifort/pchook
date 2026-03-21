import { AudibleCommand } from '~/domain/audible/command'
import { importRunner } from '~/domain/audible/use-case'

export default defineEventHandler(async () => {
  await importRunner.reset()
  await AudibleCommand.removeCredentials()
  await AudibleCommand.clearRawItems()
  await AudibleCommand.clearMappings()
  return { status: 200, data: { success: true } } as const
})
