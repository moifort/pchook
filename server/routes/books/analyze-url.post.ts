import { z } from 'zod'
import { SeriesQuery } from '~/domain/series/query'
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

  const allSeries = await SeriesQuery.findAll()
  const seriesNames = allSeries.map(({ name }) => String(name))
  const result = await ShareImporter.importFromShare(
    { url, description, rawText, attachmentTypes },
    seriesNames,
  )

  if (result === 'extraction-failed') {
    throw createError({
      statusCode: 422,
      statusMessage: "Impossible d'identifier le livre à partir de cette URL",
    })
  }

  const previewId = crypto.randomUUID()

  await previewRepository.save({
    previewId,
    scanResult: result,
    importSource: 'url',
    externalUrl: url,
    createdAt: new Date(),
  })

  return { status: 200, data: { previewId, ...result } } as const
})
