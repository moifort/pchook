import type { Award, Note, PublicRating } from '~/domain/book/types'

export const FAVORITE_RATING = 5

export const isFavorite = (rating?: Note) => rating === FAVORITE_RATING

export const awardsCount = (awards: Award[]) => awards.length

export const popularityScore = (ratings: PublicRating[]) => {
  if (ratings.length === 0) return 0
  const totalVoters = ratings.reduce((sum, { voterCount }) => sum + voterCount, 0)
  if (totalVoters === 0) return 0
  const weightedSum = ratings.reduce((sum, { score, voterCount }) => sum + score * voterCount, 0)
  return Math.round((weightedSum / totalVoters) * 100) / 100
}
