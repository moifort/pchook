import type { Award, Note } from '~/domain/book/types'

export const FAVORITE_RATING = 5

export const isFavorite = (rating?: Note) => rating === FAVORITE_RATING

export const awardsCount = (awards: Award[]) => awards.length
