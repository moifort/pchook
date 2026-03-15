import type { BookId } from '~/domain/book/types'
import * as repository from '~/domain/suggestion/repository'
import type { Suggestion } from '~/domain/suggestion/types'

export namespace SuggestionCommand {
  export const saveAll = async (suggestions: Suggestion[]) => {
    return await Promise.all(suggestions.map((s) => repository.save(s)))
  }

  export const clearForBook = async (sourceBookId: BookId) => {
    await repository.clearForBook(sourceBookId)
  }
}
