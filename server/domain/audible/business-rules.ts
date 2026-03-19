import type { AudibleItem } from '~/domain/audible/types'
import { partialScanResultSchema } from '~/system/scan/schemas'
import type { ScanResult } from '~/system/scan/types'

export const formatDuration = (minutes: number) => {
  const hours = Math.floor(minutes / 60)
  const remainingMinutes = minutes % 60
  return `${hours}h ${remainingMinutes}min`
}

export const buildGeminiPrompt = (item: AudibleItem) => {
  const authorsStr = item.authors.join(', ')
  const seriesHint = item.series
    ? `\nCe livre fait partie de la série "${item.series.name}"${item.series.position ? ` (tome ${item.series.position})` : ''}.`
    : ''

  return `Recherche le livre "${item.title}" de ${authorsStr}.${seriesHint}
Retourne toutes les informations au format JSON strict (sans markdown, sans backticks) :
{
  "title": string (titre du livre uniquement, sans préfixe de série ni numéro de tome),
  "authors": string[] (liste des auteurs),
  "publisher": string ou null (maison d'édition),
  "publishedDate": string ou null (date de première publication, format YYYY-MM-DD ou YYYY),
  "pageCount": number ou null,
  "genre": string ou null (sous-genres séparés par des virgules, ex: "LitRPG, Science Fantasy" — sois précis et spécifique),
  "synopsis": string ou null (résumé de 3-5 phrases en français, pas la 4ème de couverture mais un vrai résumé du contenu),
  "isbn": string ou null (ISBN-13 de préférence),
  "language": string ou null (code ISO 639-1 en majuscules — ex: "FR", "EN", "ES"),
  "format": string ou null ("pocket", "paperback", "hardcover" ou "audiobook"),
  "series": string ou null (nom de la série ou du cycle),
  "seriesNumber": number ou null (numéro du tome dans la série),
  "translator": string ou null (traducteur si c'est une traduction),
  "estimatedPrice": number ou null (prix moyen en euros sur les librairies françaises),
  "awards": [{"name": string, "year": number}] (IMPORTANT : nom COURT du prix uniquement, JAMAIS la sous-catégorie ou spécialité. Exemples corrects : "Prix Hugo", "Prix Nebula", "Grand Prix de l'Imaginaire", "Prix Goncourt". Exemples INCORRECTS : "Prix Hugo du meilleur roman", "Prix Nebula du meilleur roman court". Tableau vide si aucun prix),
  "publicRatings": [{"source": string, "score": number, "maxScore": number, "voterCount": number}] (cherche les notes actuelles sur toutes les plateformes pertinentes : Goodreads /5, Babelio /5, Sens Critique /10, Amazon /5, etc.)
}
Toutes les valeurs textuelles en français.`
}

export const mergeAudibleIntoScanResult = (
  scanResult: Record<string, unknown>,
  item: AudibleItem,
): ScanResult => {
  const base = partialScanResultSchema.parse(scanResult)

  return {
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
    seriesNumber: item.series?.position ?? base.seriesNumber,
    translator: base.translator,
    estimatedPrice: base.estimatedPrice,
    duration: item.durationMinutes > 0 ? formatDuration(item.durationMinutes) : undefined,
    narrators: item.narrators,
    awards: base.awards,
    publicRatings: base.publicRatings,
  }
}
