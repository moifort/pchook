import type { AudibleItem } from '~/domain/audible/types'
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
  const base: ScanResult = {
    title: scanResult.title as string,
    authors: (scanResult.authors as string[]) ?? [],
    publisher: scanResult.publisher as string | undefined,
    publishedDate: scanResult.publishedDate as string | undefined,
    pageCount: scanResult.pageCount as number | undefined,
    genre: scanResult.genre as string | undefined,
    synopsis: scanResult.synopsis as string | undefined,
    isbn: scanResult.isbn as string | undefined,
    language: scanResult.language as string | undefined,
    format: scanResult.format as string | undefined,
    series: scanResult.series as string | undefined,
    seriesNumber: scanResult.seriesNumber as number | undefined,
    translator: scanResult.translator as string | undefined,
    estimatedPrice: scanResult.estimatedPrice as number | undefined,
    duration: scanResult.duration as string | undefined,
    narrators: scanResult.narrators as string[] | undefined,
    awards: Array.isArray(scanResult.awards) ? (scanResult.awards as ScanResult['awards']) : [],
    publicRatings: Array.isArray(scanResult.publicRatings)
      ? (scanResult.publicRatings as ScanResult['publicRatings'])
      : [],
  }

  return {
    ...base,
    title: item.title,
    authors: item.authors,
    format: 'audiobook',
    narrators: item.narrators,
    duration: item.durationMinutes > 0 ? formatDuration(item.durationMinutes) : undefined,
    publisher: item.publisher ?? base.publisher,
    language: item.language ?? base.language,
    series: item.series?.name ?? base.series,
    seriesNumber: item.series?.position ?? base.seriesNumber,
    publishedDate: item.releaseDate
      ? item.releaseDate.toISOString().split('T')[0]
      : base.publishedDate,
  }
}
