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

export const LanguageEnum = builder.enumType('Language', {
  description: 'ISO 639-1 language code',
  values: {
    FR: { value: 'fr' as const, description: 'French' },
    EN: { value: 'en' as const, description: 'English' },
    ES: { value: 'es' as const, description: 'Spanish' },
    DE: { value: 'de' as const, description: 'German' },
    IT: { value: 'it' as const, description: 'Italian' },
    PT: { value: 'pt' as const, description: 'Portuguese' },
    JA: { value: 'ja' as const, description: 'Japanese' },
    ZH: { value: 'zh' as const, description: 'Chinese' },
    KO: { value: 'ko' as const, description: 'Korean' },
    RU: { value: 'ru' as const, description: 'Russian' },
    NL: { value: 'nl' as const, description: 'Dutch' },
    PL: { value: 'pl' as const, description: 'Polish' },
    SV: { value: 'sv' as const, description: 'Swedish' },
    AR: { value: 'ar' as const, description: 'Arabic' },
    CS: { value: 'cs' as const, description: 'Czech' },
    DA: { value: 'da' as const, description: 'Danish' },
    FI: { value: 'fi' as const, description: 'Finnish' },
    EL: { value: 'el' as const, description: 'Greek' },
    HU: { value: 'hu' as const, description: 'Hungarian' },
    NO: { value: 'no' as const, description: 'Norwegian' },
    RO: { value: 'ro' as const, description: 'Romanian' },
    TR: { value: 'tr' as const, description: 'Turkish' },
    UK: { value: 'uk' as const, description: 'Ukrainian' },
    HE: { value: 'he' as const, description: 'Hebrew' },
    HI: { value: 'hi' as const, description: 'Hindi' },
    TH: { value: 'th' as const, description: 'Thai' },
    VI: { value: 'vi' as const, description: 'Vietnamese' },
    ID: { value: 'id' as const, description: 'Indonesian' },
    CA: { value: 'ca' as const, description: 'Catalan' },
    LA: { value: 'la' as const, description: 'Latin' },
  },
})
