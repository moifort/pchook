import { z } from 'zod'
import { BookUseCase } from '~/domain/book/use-case'
import { scanResultToBookData } from '~/system/scan/to-book-data'
import { UrlImporter } from '~/system/scan/url-import'

const bodySchema = z.object({ url: z.string().url() })

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { url } = bodySchema.parse(body)

  const { scanResult, coverImageBase64 } = await UrlImporter.importFromUrl(url)
  const { title, data, seriesInfo } = scanResultToBookData(scanResult)
  const result = await BookUseCase.addFromScan(title, data, seriesInfo, coverImageBase64)

  if (result.tag === 'duplicate') {
    setResponseStatus(event, 409)
    return { status: 409, data: result.book } as const
  }

  return { status: 201, data: result.book } as const
})
