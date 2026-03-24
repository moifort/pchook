import { FAVORITE_RATING } from '~/domain/book/business-rules'
import type { BookId } from '~/domain/book/types'
import * as repository from '~/domain/review/infrastructure/repository'

export namespace ReviewQuery {
  export const getByBookId = async (bookId: BookId) => {
    const review = await repository.findBy(bookId)
    if (!review) return 'not-found' as const
    return review
  }

  export const getAll = () => repository.findAll()

  export const getFavorites = async () => {
    const all = await repository.findAll()
    return all.filter(({ rating }) => rating === FAVORITE_RATING)
  }
}
