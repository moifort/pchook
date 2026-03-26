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
    myRating: { description: 'Personal rating' },
    publishedDate: { description: 'Publication date' },
  } as const,
})

export const SortOrderEnum = builder.enumType('SortOrder', {
  description: 'Sort order',
  values: {
    asc: { description: 'Ascending' },
    desc: { description: 'Descending' },
  } as const,
})

export const LanguageEnum = builder.enumType('Language', {
  description: 'ISO 639-1 language code',
  values: {
    fr: { description: 'French' },
    en: { description: 'English' },
    es: { description: 'Spanish' },
    de: { description: 'German' },
    it: { description: 'Italian' },
    pt: { description: 'Portuguese' },
    ja: { description: 'Japanese' },
    zh: { description: 'Chinese' },
    ko: { description: 'Korean' },
    ru: { description: 'Russian' },
    nl: { description: 'Dutch' },
    pl: { description: 'Polish' },
    sv: { description: 'Swedish' },
    ar: { description: 'Arabic' },
    cs: { description: 'Czech' },
    da: { description: 'Danish' },
    fi: { description: 'Finnish' },
    el: { description: 'Greek' },
    hu: { description: 'Hungarian' },
    no: { description: 'Norwegian' },
    ro: { description: 'Romanian' },
    tr: { description: 'Turkish' },
    uk: { description: 'Ukrainian' },
    he: { description: 'Hebrew' },
    hi: { description: 'Hindi' },
    th: { description: 'Thai' },
    vi: { description: 'Vietnamese' },
    id: { description: 'Indonesian' },
    ca: { description: 'Catalan' },
    la: { description: 'Latin' },
  } as const,
})
