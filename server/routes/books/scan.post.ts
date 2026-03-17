import {
  BookFormat,
  BookTitle,
  Genre,
  ISBN,
  Language,
  Note,
  PageCount,
  Publisher,
} from '~/domain/book/primitives'
import type { Award, PublicRating } from '~/domain/book/types'
import { BookUseCase } from '~/domain/book/use-case'
import { Eur, PersonName } from '~/domain/shared/primitives'
import { BookScanner } from '~/system/scan/index'

export default defineEventHandler(async (event) => {
  const rawBody = await readRawBody(event, false)
  if (!rawBody) throw createError({ statusCode: 400, statusMessage: 'No image data provided' })

  const imageBuffer = Buffer.from(rawBody)
  const scanResult = await BookScanner.scan(imageBuffer)

  const title = BookTitle(scanResult.title)
  const authors = scanResult.authors.map((a) => PersonName(a))

  const data = {
    authors,
    publisher: scanResult.publisher ? Publisher(scanResult.publisher) : undefined,
    publishedDate: scanResult.publishedDate ? new Date(scanResult.publishedDate) : undefined,
    pageCount: scanResult.pageCount ? PageCount(scanResult.pageCount) : undefined,
    genre: scanResult.genre ? Genre(scanResult.genre) : undefined,
    synopsis: scanResult.synopsis,
    isbn: scanResult.isbn ? ISBN(scanResult.isbn) : undefined,
    language: scanResult.language ? Language(scanResult.language) : undefined,
    format: scanResult.format ? BookFormat(scanResult.format) : undefined,
    translator: scanResult.translator ? PersonName(scanResult.translator) : undefined,
    estimatedPrice: scanResult.estimatedPrice ? Eur(scanResult.estimatedPrice) : undefined,
    awards: scanResult.awards as Award[],
    publicRatings: scanResult.publicRatings
      .filter(({ score, maxScore }) => score != null && maxScore != null)
      .map(({ source, score, maxScore, voterCount }) => ({
        source,
        score: Note(score),
        maxScore: Note(maxScore),
        voterCount,
      })) as PublicRating[],
  }

  const seriesInfo = scanResult.series
    ? { name: scanResult.series, number: scanResult.seriesNumber }
    : undefined

  const coverImageBase64 = imageBuffer.toString('base64')
  const result = await BookUseCase.addFromScan(title, data, seriesInfo, coverImageBase64)

  if (result.tag === 'duplicate') {
    setResponseStatus(event, 409)
    return { status: 409, data: result.book } as const
  }

  return { status: 201, data: result.book } as const
})
