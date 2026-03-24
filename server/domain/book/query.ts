import * as repository from '~/domain/book/repository'
import type { BookId, ISBN } from '~/domain/book/types'

export namespace BookQuery {
  export const findAll = () => repository.findAll()

  export const getById = async (id: BookId) => {
    const book = await repository.findBy(id)
    if (!book) return 'not-found' as const
    return book
  }

  export const findByISBN = (isbn: ISBN) => repository.findByISBN(isbn)

  export const findByTitleAndAuthors = (title: string, authors: string[]) =>
    repository.findByTitleAndAuthors(title, authors)
}
