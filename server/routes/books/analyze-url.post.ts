import { z } from 'zod'
import * as previewRepository from '~/system/scan/preview-repository'
import { UrlImporter } from '~/system/scan/url-import'

const bodySchema = z.object({ url: z.string().url(), description: z.string().optional() })

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { url, description } = bodySchema.parse(body)

  const { scanResult, coverImageBase64 } = await UrlImporter.importFromUrl(url, description)
  const previewId = crypto.randomUUID()

  await previewRepository.save({
    previewId,
    scanResult,
    coverImageBase64,
    createdAt: new Date(),
  })

  return { status: 200, data: { previewId, ...scanResult, coverImageBase64 } } as const
})
