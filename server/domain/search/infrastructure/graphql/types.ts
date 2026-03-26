import { getRequestURL } from 'h3'
import type {
  AuthorSearchResult,
  BookSearchResult,
  SearchResults,
  SeriesSearchResult,
} from '~/domain/search/types'
import { builder } from '~/domain/shared/graphql/builder'

export const BookSearchResultType = builder
  .objectRef<BookSearchResult>('BookSearchResult')
  .implement({
    description: 'A book matching a search query',
    fields: (t) => ({
      id: t.id({ description: 'Book ID', resolve: ({ id }) => id }),
      title: t.exposeString('title', { description: 'Book title' }),
      authors: t.stringList({
        description: 'Book authors',
        resolve: ({ authors }) => authors,
      }),
      language: t.string({
        nullable: true,
        description: 'Book language (ISO 639-1)',
        resolve: ({ language }) => language ?? null,
      }),
      status: t.exposeString('status', { description: 'Reading status' }),
      coverImageUrl: t.field({
        type: 'Url',
        nullable: true,
        description: 'Cover image URL',
        resolve: ({ coverImageId }, _, { event }) => {
          if (!coverImageId) return null
          const origin = getRequestURL(event).origin
          return `${origin}/images/${coverImageId}` as never
        },
      }),
    }),
  })

export const SeriesSearchResultType = builder
  .objectRef<SeriesSearchResult>('SeriesSearchResult')
  .implement({
    description: 'A series matching a search query',
    fields: (t) => ({
      id: t.id({ description: 'Series ID', resolve: ({ id }) => id }),
      name: t.field({
        type: 'SeriesName',
        description: 'Series name',
        resolve: ({ name }) => name as never,
      }),
      volumeCount: t.int({
        description: 'Number of volumes in the series',
        resolve: ({ volumeCount }) => volumeCount,
      }),
      rating: t.field({
        type: 'Note',
        nullable: true,
        description: 'Personal series rating',
        resolve: ({ rating }) => (rating as never) ?? null,
      }),
      languages: t.stringList({
        description: 'Languages of books in the series (ISO 639-1)',
        resolve: ({ languages }) => languages,
      }),
    }),
  })

export const AuthorSearchResultType = builder
  .objectRef<AuthorSearchResult>('AuthorSearchResult')
  .implement({
    description: 'An author matching a search query',
    fields: (t) => ({
      name: t.field({
        type: 'PersonName',
        description: 'Author name',
        resolve: ({ name }) => name as never,
      }),
      bookCount: t.int({
        description: 'Number of books by this author',
        resolve: ({ bookCount }) => bookCount,
      }),
      firstBookId: t.id({
        description: 'ID of the first book by this author',
        resolve: ({ firstBookId }) => firstBookId,
      }),
    }),
  })

export const SearchResultsType = builder.objectRef<SearchResults>('SearchResults').implement({
  description: 'Grouped search results across all domains',
  fields: (t) => ({
    books: t.field({
      type: [BookSearchResultType],
      description: 'Matching books',
      resolve: ({ books }) => books,
    }),
    series: t.field({
      type: [SeriesSearchResultType],
      description: 'Matching series',
      resolve: ({ series }) => series,
    }),
    authors: t.field({
      type: [AuthorSearchResultType],
      description: 'Matching authors',
      resolve: ({ authors }) => authors,
    }),
  }),
})
