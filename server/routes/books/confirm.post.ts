import { match } from 'ts-pattern'
import { z } from 'zod'
import { BookId } from '~/domain/book/primitives'
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
  replaceBookId: z.string().uuid().optional(),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { previewId, status, overrides, replaceBookId } = bodySchema.parse(body)

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

  if (replaceBookId) {
    const result = await BookUseCase.replaceFromScan(
      BookId(replaceBookId),
      title,
      { ...data, status },
      seriesInfo,
      preview.coverImageBase64,
    )

    await previewRepository.remove(previewId)

    return match(result)
      .with({ tag: 'replaced' }, ({ book }) => ({ status: 200, data: book }) as const)
      .with({ tag: 'not-found' }, () => {
        throw createError({ statusCode: 404, statusMessage: 'Book to replace not found' })
      })
      .exhaustive()
  }

  const result = await BookUseCase.addFromScan(
    title,
    { ...data, status },
    seriesInfo,
    preview.coverImageBase64,
  )

  return match(result)
    .with({ tag: 'created' }, ({ book }) => {
      previewRepository.remove(previewId)
      return { status: 201, data: book } as const
    })
    .with({ tag: 'duplicate' }, ({ book }) => {
      setResponseStatus(event, 409)
      return { status: 409, data: book } as const
    })
    .exhaustive()
})
