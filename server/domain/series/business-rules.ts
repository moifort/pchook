import type { Language } from '~/domain/book/types'

type WithLanguage = {
  language?: Language
  [key: string]: unknown
}

export const booksInLanguage = <T extends WithLanguage>(books: T[], language?: Language) =>
  books.filter(({ language: bookLanguage }) => bookLanguage === language)
