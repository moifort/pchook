import type { AudibleItem } from '~/domain/audible/types'
import { buildBookJsonSchema } from '~/system/scan/gemini'
import type { ScanResult } from '~/system/scan/types'

export const formatDuration = (minutes: number) => {
  const hours = Math.floor(minutes / 60)
  const remainingMinutes = minutes % 60
  return `${hours}h ${remainingMinutes}min`
}

export const buildGeminiPrompt = (item: AudibleItem, existingSeriesNames: string[] = []) => {
  const authorsStr = item.authors.join(', ')
  const seriesHint = item.series
    ? `\nCe livre fait partie de la série "${item.series.name}"${item.series.position ? ` (tome ${item.series.position})` : ''}.`
    : ''

  return `Recherche le livre "${item.title}" de ${authorsStr}.${seriesHint}
Retourne toutes les informations au format JSON strict (sans markdown, sans backticks) :

${buildBookJsonSchema(true, existingSeriesNames)}

Toutes les valeurs textuelles en français.`
}

export const mergeAudibleIntoScanResult = (base: ScanResult, item: AudibleItem): ScanResult => ({
  title: item.title,
  authors: item.authors,
  publisher: item.publisher ?? base.publisher,
  publishedDate: item.releaseDate
    ? item.releaseDate.toISOString().split('T')[0]
    : base.publishedDate,
  pageCount: base.pageCount,
  genre: base.genre,
  synopsis: base.synopsis,
  isbn: base.isbn,
  language: item.language ?? base.language,
  format: 'audiobook',
  series: item.series?.name ?? base.series,
  seriesLabel: item.series?.position ? String(item.series.position) : base.seriesLabel,
  seriesNumber: item.series?.position ?? base.seriesNumber,
  translator: base.translator,
  estimatedPrice: base.estimatedPrice,
  duration: item.durationMinutes > 0 ? formatDuration(item.durationMinutes) : undefined,
  narrators: item.narrators,
  awards: base.awards,
  publicRatings: base.publicRatings,
})
