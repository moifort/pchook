import type { BookId } from '~/domain/book/types'
import type { Suggestion } from '~/domain/suggestion/types'

const storage = () => useStorage('suggestions')

export const findBySourceBookId = async (sourceBookId: BookId) => {
  const keys = await storage().getKeys()
  const items = await storage().getItems<Suggestion>(keys)
  return items.map(({ value }) => value).filter((s) => s.sourceBookId === sourceBookId)
}

export const save = async (suggestion: Suggestion) => {
  await storage().setItem(suggestion.id, suggestion)
  return suggestion
}

export const clearForBook = async (sourceBookId: BookId) => {
  const suggestions = await findBySourceBookId(sourceBookId)
  await Promise.all(suggestions.map((s) => storage().removeItem(s.id)))
}
