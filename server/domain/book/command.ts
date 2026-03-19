import { randomBookId } from '~/domain/book/primitives'
import * as repository from '~/domain/book/repository'
import type { Book, BookId, BookTitle } from '~/domain/book/types'

const withoutUndefined = <T extends Record<string, unknown>>(obj: T) =>
  Object.fromEntries(Object.entries(obj).filter(([, v]) => v !== undefined)) as Partial<T>

export namespace BookCommand {
  export const add = async (title: BookTitle, data: Partial<Book>) => {
    const defined = withoutUndefined(data)
    const book: Book = {
      ...defined,
      id: randomBookId(),
      title,
      authors: data.authors ?? [],
      narrators: data.narrators ?? [],
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
    const defined = withoutUndefined(data)
    return await repository.save({ ...existing, ...defined, updatedAt: new Date() })
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
