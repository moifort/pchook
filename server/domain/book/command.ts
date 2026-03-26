import type { BookAddedEvent, BookUpdatedEvent } from '~/domain/book/events'
import * as repository from '~/domain/book/infrastructure/repository'
import { randomBookId } from '~/domain/book/primitives'
import type { Book, BookId, BookTitle } from '~/domain/book/types'
import { emit } from '~/system/event-bus'

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
    const saved = await repository.save(book)
    await emit<BookAddedEvent>('book-added', { bookId: saved.id })
    return saved
  }

  export const update = async (id: BookId, data: Partial<Book>) => {
    const existing = await repository.findBy(id)
    if (!existing) return 'not-found' as const
    const defined = withoutUndefined(data)
    const saved = await repository.save({ ...existing, ...defined, updatedAt: new Date() })
    await emit<BookUpdatedEvent>('book-updated', { bookId: saved.id })
    return saved
  }

  export const remove = async (id: BookId) => {
    const existing = await repository.findBy(id)
    if (!existing) return 'not-found' as const
    return await repository.remove(id)
  }
}
