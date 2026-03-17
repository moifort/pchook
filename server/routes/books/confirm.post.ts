import { z } from 'zod'
import { BookUseCase } from '~/domain/book/use-case'
import * as previewRepository from '~/system/scan/preview-repository'
import { scanResultToBookData } from '~/system/scan/to-book-data'

const bodySchema = z.object({
  previewId: z.string().uuid(),
  status: z.enum(['to-read', 'read']),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { previewId, status } = bodySchema.parse(body)

  const preview = await previewRepository.findBy(previewId)
  if (!preview) {
    throw createError({ statusCode: 404, statusMessage: 'Preview not found or expired' })
  }

  const { title, data, seriesInfo } = scanResultToBookData(preview.scanResult)
  const result = await BookUseCase.addFromScan(
    title,
    { ...data, status },
    seriesInfo,
    preview.coverImageBase64,
  )

  await previewRepository.remove(previewId)

  if (result.tag === 'duplicate') {
    setResponseStatus(event, 409)
    return { status: 409, data: result.book } as const
  }

  return { status: 201, data: result.book } as const
})
