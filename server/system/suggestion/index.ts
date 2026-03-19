import { z } from 'zod'
import { BookTitle as makeBookTitle, Genre as makeGenre, Note } from '~/domain/book/primitives'
import type { BookId, BookTitle, Genre } from '~/domain/book/types'
import { PersonName as makePersonName } from '~/domain/shared/primitives'
import type { PersonName } from '~/domain/shared/types'
import { randomSuggestionId } from '~/domain/suggestion/primitives'
import type { Suggestion } from '~/domain/suggestion/types'
import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'

const log = createLogger('suggestion')

const GEMINI_API_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'

export namespace SuggestionGenerator {
  export const generate = async (
    sourceBookId: BookId,
    bookTitle: string,
    authors: string[],
    genre?: string,
  ): Promise<Suggestion[]> => {
    const { googleApiKey } = config()

    const bookDescription = [bookTitle, authors.join(', '), genre].filter(Boolean).join(', ')

    const prompt = `Je viens de lire "${bookDescription}".

Suggère-moi 5 livres similaires que je pourrais aimer, du même thème ou genre. Pour chaque livre, donne-moi les informations au format JSON strict (sans markdown) :

[
  {
    "title": string,
    "authors": string[],
    "genre": string ou null,
    "synopsis": string (2-3 phrases en français),
    "awards": [{"name": string, "year": number}] (prix littéraires reçus, tableau vide si aucun),
    "publicRatings": [{"source": string, "score": number, "maxScore": 5, "voterCount": number}] (notes Goodreads, Babelio, etc.)
  }
]

Trie les résultats par popularité (note la plus haute × nombre de votants) puis par nombre de prix reçus.
Toutes les valeurs en français. Données les plus récentes.`

    try {
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
      if (!text) return []

      const jsonMatch = text.match(/\[[\s\S]*\]/)
      if (!jsonMatch) return []

      const suggestionItemSchema = z.object({
        title: z.string().min(1),
        authors: z.array(z.string().min(1)).default([]),
        genre: z
          .string()
          .min(1)
          .nullish()
          .transform((v) => v ?? undefined),
        synopsis: z
          .string()
          .nullish()
          .transform((v) => v ?? undefined),
        awards: z
          .array(
            z.object({
              name: z.string().min(1),
              year: z
                .number()
                .int()
                .positive()
                .nullish()
                .transform((v) => v ?? undefined),
            }),
          )
          .default([]),
        publicRatings: z
          .array(
            z.object({
              source: z.string().min(1),
              score: z.number(),
              maxScore: z.number(),
              voterCount: z.number().int().nonnegative(),
            }),
          )
          .default([]),
      })

      const raw = z.array(suggestionItemSchema).parse(JSON.parse(jsonMatch[0]))

      return raw.map((item) => ({
        id: randomSuggestionId(),
        sourceBookId,
        title: makeBookTitle(item.title) as BookTitle,
        authors: item.authors.map((author) => makePersonName(author) as PersonName),
        genre: item.genre ? (makeGenre(item.genre) as Genre) : undefined,
        synopsis: item.synopsis,
        awards: item.awards,
        publicRatings: item.publicRatings.map((rating) => ({
          source: rating.source,
          score: Note(Math.min(rating.score, rating.maxScore)),
          maxScore: Note(rating.maxScore),
          voterCount: rating.voterCount,
        })),
        createdAt: new Date(),
      }))
    } catch (error) {
      log.error('Failed to generate suggestions', error)
      return []
    }
  }
}
