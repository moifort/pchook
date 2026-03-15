import type { BookId } from '~/domain/book/types'
import * as repository from '~/domain/review/repository'
import type { Review } from '~/domain/review/types'

export namespace ReviewCommand {
  export const create = async (review: Review) => {
    return await repository.save(review)
  }

  export const removeBook = async (bookId: BookId) => {
    await repository.remove(bookId)
  }
}
