import type { BookFormat } from '~/domain/book/types'
import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'

const log = createLogger('gemini')

const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'

const formatAliases: Record<string, BookFormat> = {
  pocket: 'pocket',
  poche: 'pocket',
  'format poche': 'pocket',
  'livre de poche': 'pocket',
  'mass market': 'pocket',
  'mass market paperback': 'pocket',
  paperback: 'paperback',
  broché: 'paperback',
  'grand format': 'paperback',
  'trade paperback': 'paperback',
  hardcover: 'hardcover',
  relié: 'hardcover',
  cartonné: 'hardcover',
  'couverture rigide': 'hardcover',
  audiobook: 'audiobook',
  'livre audio': 'audiobook',
  audio: 'audiobook',
}

export const normalizeBookFormat = (value: string | undefined): BookFormat | undefined => {
  if (!value) return undefined
  const normalized = formatAliases[value.toLowerCase().trim()]
  if (!normalized) log.warn('Unknown book format, discarding', value)
  return normalized
}

export const buildBookJsonSchema = (
  includeIdentification: boolean,
  existingSeriesNames: string[] = [],
) => {
  const identificationFields = includeIdentification
    ? `  "title": string (titre du livre uniquement, sans préfixe de série ni numéro de tome — ex: "Le Nom du Vent" et non "Tome 1 : Le Nom du Vent"),
  "authors": string[] (liste des auteurs),
`
    : ''

  return `{
${identificationFields}  "publisher": string ou null (maison d'édition),
  "publishedDate": string ou null (date de première publication, format YYYY-MM-DD ou YYYY),
  "pageCount": number ou null,
  "genre": string ou null (sous-genres séparés par des virgules, ex: "LitRPG, Science Fantasy" ou "Thriller, Policier" — sois précis et spécifique),
  "synopsis": string ou null (résumé de 3-5 phrases en français, pas la 4ème de couverture mais un vrai résumé du contenu),
  "isbn": string ou null (ISBN-13 de préférence),
  "language": string ou null (code ISO 639-1 en majuscules — ex: "FR", "EN", "ES"),
  "format": string ou null ("pocket", "paperback", "hardcover" ou "audiobook"),
  "series": string ou null (nom de la série, du cycle, de la trilogie ou de la saga — recherche activement si ce livre fait partie d'une série même si ce n'est pas explicitement marqué),${existingSeriesNames.length > 0 ? `\n  IMPORTANT : si ce livre fait partie d'une série, vérifie d'abord si elle correspond à une de ces séries existantes : ${existingSeriesNames.map((name) => `"${name}"`).join(', ')}. Utilise le nom existant exact si c'est la même série, même si tu trouves une variante différente.` : ''}
  "seriesLabel": string ou null (libellé du tome tel qu'affiché : "1", "1.5", "Hors-série", "Préquelle", "Extra" — texte libre),
  "seriesNumber": number ou null (position de tri dans la série : nombre décimal, ex: 0.5 pour une préquelle, 1.5 pour un interlude, 99 pour un hors-série en fin de série),
  "translator": string ou null (traducteur si c'est une traduction),
  "estimatedPrice": number ou null (prix moyen en euros sur les librairies françaises),
  "duration": string ou null (durée totale, format "Xh Ymin" — uniquement si le format est audiobook),
  "narrators": string[] ou null (narrateurs/conteurs de l'audiobook — uniquement si le format est audiobook),
  "awards": [{"name": string, "year": number}] (IMPORTANT : nom COURT du prix uniquement, JAMAIS la sous-catégorie ou spécialité. Exemples corrects : "Prix Hugo", "Prix Nebula", "Grand Prix de l'Imaginaire", "Prix Goncourt". Exemples INCORRECTS : "Prix Hugo du meilleur roman", "Prix Nebula du meilleur roman court", "Grand Prix de l'Imaginaire du meilleur roman francophone". Tableau vide si aucun prix),
  "publicRatings": [{"source": string, "score": number, "maxScore": number, "voterCount": number}] (cherche les notes actuelles sur toutes les plateformes pertinentes : Goodreads /5, Babelio /5, Sens Critique /10, Amazon /5, etc. — inclus chaque source trouvée avec son score, son barème et le nombre de votants)
}`
}

const cleanGeminiJson = (raw: string) =>
  raw
    .replace(/,\s*]/g, ']')
    .replace(/,\s*}/g, '}')
    // Fix: "value" ou "other" → "value"
    .replace(/"([^"]*?)"\s+ou\s+[^,}\]]+/g, '"$1"')
    // Fix: 123 ou 456 → 123
    .replace(/(\d+)\s+ou\s+\d+/g, '$1')

export const parseGeminiJson = (text: string) => {
  const withoutFences = text.replace(/```(?:json)?\s*([\s\S]*?)```/g, '$1')

  const jsonMatch = withoutFences.match(/\{[\s\S]*\}/)
  if (!jsonMatch) throw new Error(`Gemini did not return valid JSON: ${text.slice(0, 200)}`)

  try {
    return JSON.parse(jsonMatch[0]) as Record<string, unknown>
  } catch {
    try {
      return JSON.parse(cleanGeminiJson(jsonMatch[0])) as Record<string, unknown>
    } catch {
      throw new Error(`Gemini returned unparseable JSON: ${jsonMatch[0].slice(0, 300)}`)
    }
  }
}

export const callGemini = async (prompt: string) => {
  const { googleApiKey } = config()

  const response = await $fetch<{
    candidates: { content: { parts: { text?: string }[] } }[]
  }>(`${GEMINI_API_URL}?key=${googleApiKey}`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: {
      contents: [{ parts: [{ text: prompt }] }],
      tools: [{ google_search: {} }],
    },
  })

  const text = response.candidates?.[0]?.content?.parts?.find((part) => part.text)?.text
  if (!text) throw new Error('Gemini did not return any text')

  log.info('Gemini raw response', text)

  return parseGeminiJson(text)
}
