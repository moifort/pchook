import { randomBookId } from '~/domain/book/primitives'
import * as repository from '~/domain/book/repository'
import type { Book, BookId, BookTitle } from '~/domain/book/types'

export namespace BookCommand {
  export const add = async (title: BookTitle, data: Partial<Book>) => {
    const book: Book = {
      ...data,
      id: randomBookId(),
      title,
      authors: data.authors ?? [],
      status: data.status ?? 'to-read',
      awards: data.awards ?? [],
      publicRatings: data.publicRatings ?? [],
      createdAt: new Date(),
      updatedAt: new Date(),
    }
    return await repository.save(book)
  }

  export const update = async (id: BookId, data: Partial<Book>) => {
    const existing = await repository.findBy(id)
    if (!existing) return 'not-found' as const
    return await repository.save({ ...existing, ...data, updatedAt: new Date() })
  }

  export const remove = async (id: BookId) => {
    const existing = await repository.findBy(id)
    if (!existing) return 'not-found' as const
    return await repository.remove(id)
  }

  export const saveImage = async (id: BookId, imageBase64: string) => {
    await repository.saveImage(id, imageBase64)
  }
}
