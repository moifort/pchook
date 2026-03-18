import { z } from 'zod'
import { BookUseCase } from '~/domain/book/use-case'
import * as previewRepository from '~/system/scan/preview-repository'
import { scanResultToBookData } from '~/system/scan/to-book-data'

const overridesSchema = z
  .object({
    title: z.string().optional(),
    authors: z.array(z.string()).optional(),
    publisher: z.string().optional(),
    pageCount: z.number().optional(),
    genre: z.string().optional(),
    synopsis: z.string().optional(),
    language: z.string().optional(),
    format: z.string().optional(),
    translator: z.string().optional(),
    estimatedPrice: z.number().optional(),
    series: z.string().optional(),
    seriesNumber: z.number().optional(),
  })
  .optional()

const bodySchema = z.object({
  previewId: z.string().uuid(),
  status: z.enum(['to-read', 'read']),
  overrides: overridesSchema,
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { previewId, status, overrides } = bodySchema.parse(body)

  const preview = await previewRepository.findBy(previewId)
  if (!preview) {
    throw createError({ statusCode: 404, statusMessage: 'Preview not found or expired' })
  }

  const mergedScanResult = overrides
    ? {
        ...preview.scanResult,
        ...Object.fromEntries(Object.entries(overrides).filter(([, v]) => v !== undefined)),
      }
    : preview.scanResult
  const { title, data, seriesInfo } = scanResultToBookData(mergedScanResult)
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
