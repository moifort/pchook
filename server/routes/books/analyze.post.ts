import { z } from 'zod'
import { SeriesQuery } from '~/domain/series/query'
import { createLogger } from '~/system/logger'
import { BookScanner } from '~/system/scan/index'
import * as previewRepository from '~/system/scan/preview-repository'

const bodySchema = z.object({
  imageBase64: z.string().min(1),
  ocrText: z.string().optional(),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { imageBase64, ocrText } = bodySchema.parse(body)

  const log = createLogger('analyze')
  log.info('Received analyze request', {
    imageSize: imageBase64.length,
    ocrText: ocrText ?? null,
  })

  const imageBuffer = Buffer.from(imageBase64, 'base64')
  const allSeries = await SeriesQuery.findAll()
  const seriesNames = allSeries.map(({ name }) => String(name))
  const scanResult = await BookScanner.scan(imageBuffer, ocrText, seriesNames)
  const previewId = crypto.randomUUID()

  await previewRepository.save({
    previewId,
    scanResult,
    coverImageBase64: imageBase64,
    importSource: 'scan',
    createdAt: new Date(),
  })

  return { status: 200, data: { previewId, ...scanResult } } as const
})
