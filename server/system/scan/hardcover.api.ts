import { config } from '~/system/config/index'
import { createLogger } from '~/system/logger'

const log = createLogger('hardcover')

const HARDCOVER_API_URL = 'https://api.hardcover.app/v1/graphql'

type HardcoverRating = {
  score: number
  maxScore: number
  voterCount: number
  url: string
}

export type HardcoverBookData = {
  rating?: HardcoverRating
  genres: string[]
  pageCount?: number
}

type GraphQLResponse<T> = {
  data?: T
  errors?: { message: string }[]
}

type SearchResult = {
  search: {
    results: {
      hits: {
        document: {
          id: number
          slug: string
          title: string
          author_names: string[]
        }
      }[]
    }
  }
}

type BookResult = {
  books: {
    id: number
    slug: string
    rating: number | null
    ratings_count: number | null
    pages: number | null
    cached_tags: Record<string, { tag: string; count: number }[]> | null
  }[]
}

type EditionResult = {
  editions: {
    book_id: number
    book: {
      id: number
      slug: string
      rating: number | null
      ratings_count: number | null
      pages: number | null
      cached_tags: Record<string, { tag: string; count: number }[]> | null
    }
  }[]
}

const query = async <T>(graphqlQuery: string, variables: Record<string, unknown> = {}) => {
  const { hardcoverApiToken } = config()
  if (!hardcoverApiToken) return undefined

  const response = await $fetch<GraphQLResponse<T>>(HARDCOVER_API_URL, {
    method: 'POST',
    headers: {
      authorization: `Bearer ${String(hardcoverApiToken)}`,
      'content-type': 'application/json',
    },
    body: { query: graphqlQuery, variables },
  })

  if (response.errors?.length) {
    log.warn(
      'GraphQL errors',
      response.errors.map(({ message }) => message),
    )
    return undefined
  }

  return response.data
}

const toBookData = (book: {
  slug: string
  rating: number | null
  ratings_count: number | null
  pages: number | null
  cached_tags: Record<string, { tag: string; count: number }[]> | null
}): HardcoverBookData => {
  const genres = (book.cached_tags?.['Genre'] ?? []).map(({ tag }) => tag)

  const rating: HardcoverRating | undefined =
    book.rating != null && book.ratings_count != null && book.ratings_count > 0
      ? {
          score: book.rating,
          maxScore: 5,
          voterCount: book.ratings_count,
          url: `https://hardcover.app/books/${book.slug}`,
        }
      : undefined

  return {
    rating,
    genres,
    pageCount: book.pages ?? undefined,
  }
}

const BOOK_FIELDS = `
  slug
  rating
  ratings_count
  pages
  cached_tags
`

export const searchByIsbn = async (isbn: string): Promise<HardcoverBookData | undefined> => {
  log.info('Searching by ISBN', isbn)

  const data = await query<EditionResult>(
    `query ($isbn: String!) {
      editions(where: { isbn_13: { _eq: $isbn } }, limit: 1) {
        book_id
        book { ${BOOK_FIELDS} }
      }
    }`,
    { isbn },
  )

  const edition = data?.editions[0]
  if (!edition) {
    log.info('No edition found for ISBN', isbn)
    return undefined
  }

  return toBookData(edition.book)
}

export const searchByTitle = async (
  title: string,
  authors: string[],
): Promise<HardcoverBookData | undefined> => {
  const searchQuery = [title, ...authors].join(' ')
  log.info('Searching by title', searchQuery)

  const searchData = await query<SearchResult>(
    `query ($q: String!) {
      search(query: $q, query_type: "books", per_page: 1) {
        results
      }
    }`,
    { q: searchQuery },
  )

  const hit = searchData?.search?.results?.hits?.[0]
  if (!hit) {
    log.info('No search result for', searchQuery)
    return undefined
  }

  const bookId = hit.document.id

  const bookData = await query<BookResult>(
    `query ($id: Int!) {
      books(where: { id: { _eq: $id } }, limit: 1) { ${BOOK_FIELDS} }
    }`,
    { id: bookId },
  )

  const book = bookData?.books[0]
  if (!book) return undefined

  return toBookData(book)
}
