import { BookId } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { SuggestionCommand } from '~/domain/suggestion/command'
import { SuggestionQuery } from '~/domain/suggestion/query'
import { SuggestionGenerator } from '~/system/suggestion/index'

export default defineEventHandler(async (event) => {
  const id = BookId(getRouterParam(event, 'id'))

  const book = await BookQuery.getById(id)
  if (book === 'not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Book not found' })
  }

  const needsRefresh = await SuggestionQuery.needsRefresh(id)

  if (needsRefresh) {
    await SuggestionCommand.clearForBook(id)
    const newSuggestions = await SuggestionGenerator.generate(
      id,
      String(book.title),
      book.authors.map(String),
      book.genre ? String(book.genre) : undefined,
    )
    if (newSuggestions.length > 0) {
      await SuggestionCommand.saveAll(newSuggestions)
    }
  }

  const suggestions = await SuggestionQuery.getBySourceBookId(id)

  return { status: 200, data: suggestions } as const
})
