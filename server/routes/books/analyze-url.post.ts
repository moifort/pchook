import { z } from 'zod'
import * as previewRepository from '~/system/scan/preview-repository'
import { ShareImporter } from '~/system/scan/share-import'

const bodySchema = z.object({
  url: z.string().url(),
  description: z.string().optional(),
  rawText: z.string().optional(),
  attachmentTypes: z.array(z.string()).optional(),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { url, description, rawText, attachmentTypes } = bodySchema.parse(body)

  const scanResult = await ShareImporter.importFromShare({
    url,
    description,
    rawText,
    attachmentTypes,
  })
  const previewId = crypto.randomUUID()

  await previewRepository.save({
    previewId,
    scanResult,
    createdAt: new Date(),
  })

  return { status: 200, data: { previewId, ...scanResult } } as const
})
