import { builder } from '~/domain/shared/graphql/builder'

export const BookFormatEnum = builder.enumType('BookFormat', {
  description: 'Physical or digital book format',
  values: {
    pocket: { description: 'Pocket book' },
    paperback: { description: 'Paperback' },
    hardcover: { description: 'Hardcover' },
    audiobook: { description: 'Audiobook' },
    digital: { description: 'E-book' },
  } as const,
})

export const BookStatusEnum = builder.enumType('BookStatus', {
  description: 'Reading status of a book',
  values: {
    TO_READ: { value: 'to-read' as const, description: 'To read' },
    READ: { value: 'read' as const, description: 'Read' },
  },
})

export const ImportSourceEnum = builder.enumType('ImportSource', {
  description: 'Book import source',
  values: {
    scan: { description: 'Cover scan' },
    isbn: { description: 'ISBN barcode' },
    url: { description: 'External URL' },
    audible: { description: 'Audible import' },
  } as const,
})

export const BookSortEnum = builder.enumType('BookSort', {
  description: 'Sort field for the book list',
  values: {
    createdAt: { description: 'Date added' },
    title: { description: 'Alphabetical title' },
    author: { description: 'Author name' },
    awards: { description: 'Number of literary awards' },
    genre: { description: 'Literary genre' },
  } as const,
})

export const SortOrderEnum = builder.enumType('SortOrder', {
  description: 'Sort order',
  values: {
    asc: { description: 'Ascending' },
    desc: { description: 'Descending' },
  } as const,
})
