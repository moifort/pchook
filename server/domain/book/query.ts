import * as repository from '~/domain/book/repository'
import type { BookId } from '~/domain/book/types'

export namespace BookQuery {
  export const findAll = () => repository.findAll()

  export const getById = async (id: BookId) => {
    const book = await repository.findBy(id)
    if (!book) return 'not-found' as const
    return book
  }

  export const getImageById = (id: BookId) => repository.findImageBy(id)
}
