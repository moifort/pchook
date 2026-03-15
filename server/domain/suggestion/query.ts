import { sortBy } from 'lodash-es'
import { awardsCount, popularityScore } from '~/domain/book/business-rules'
import type { BookId } from '~/domain/book/types'
import * as repository from '~/domain/suggestion/repository'

const REFRESH_THRESHOLD_DAYS = 30

export namespace SuggestionQuery {
  export const getBySourceBookId = async (sourceBookId: BookId) => {
    const suggestions = await repository.findBySourceBookId(sourceBookId)
    return sortBy(suggestions, [
      (s) => -popularityScore(s.publicRatings),
      (s) => -awardsCount(s.awards),
    ])
  }

  export const needsRefresh = async (sourceBookId: BookId) => {
    const suggestions = await repository.findBySourceBookId(sourceBookId)
    if (suggestions.length === 0) return true
    const oldest = suggestions[0].createdAt
    const ageInDays = (Date.now() - new Date(oldest).getTime()) / (1000 * 60 * 60 * 24)
    return ageInDays > REFRESH_THRESHOLD_DAYS
  }
}
