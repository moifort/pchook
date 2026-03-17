import { BookScanner } from '~/system/scan/index'
import * as previewRepository from '~/system/scan/preview-repository'

export default defineEventHandler(async (event) => {
  const rawBody = await readRawBody(event, false)
  if (!rawBody) throw createError({ statusCode: 400, statusMessage: 'No image data provided' })

  const imageBuffer = Buffer.from(rawBody)
  const scanResult = await BookScanner.scan(imageBuffer)
  const previewId = crypto.randomUUID()

  await previewRepository.save({
    previewId,
    scanResult,
    createdAt: new Date(),
  })

  return { status: 200, data: { previewId, ...scanResult } } as const
})
