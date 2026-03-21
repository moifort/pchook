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
import { Eur, PersonName, Url } from '~/domain/shared/primitives'
import type { ScanResult } from '~/system/scan/types'

const ratingUrl = (source: string, isbn: string) => {
  const s = source.toLowerCase()
  if (s.includes('babelio')) return `https://www.babelio.com/isbn/${isbn}`
  if (s.includes('goodreads')) return `https://www.goodreads.com/book/isbn/${isbn}`
  if (s.includes('sens critique') || s.includes('senscritique'))
    return `https://www.senscritique.com/search?query=${isbn}`
  if (s.includes('amazon')) return `https://www.amazon.fr/dp/${isbn}`
  return undefined
}

export const scanResultToBookData = (scanResult: ScanResult) => {
  const title = BookTitle(scanResult.title)

  const data = {
    authors: scanResult.authors.map((a) => PersonName(a)),
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
    duration: scanResult.duration,
    narrators: (scanResult.narrators ?? []).map((n) => PersonName(n)),
    awards: scanResult.awards as Award[],
    publicRatings: scanResult.publicRatings
      .filter(
        ({ score, maxScore, voterCount }) =>
          score != null && maxScore != null && voterCount != null,
      )
      .map(({ source, score, maxScore, voterCount, url }) => ({
        source,
        score: Note(score),
        maxScore: Note(maxScore),
        voterCount: Math.round(voterCount),
        url: url ?? ratingUrl(source, scanResult.isbn ?? ''),
      }))
      .filter(({ url }) => url != null)
      .map(({ source, score, maxScore, voterCount, url }) => ({
        source,
        score,
        maxScore,
        voterCount,
        url: Url(url),
      })) as PublicRating[],
  }

  const seriesInfo = scanResult.series
    ? { name: scanResult.series, label: scanResult.seriesLabel, number: scanResult.seriesNumber }
    : undefined

  return { title, data, seriesInfo }
}
