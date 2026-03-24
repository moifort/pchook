import type { Book, PublicRating as PublicRatingType } from '~/domain/book/types'
import { builder } from '~/domain/shared/graphql/builder'
import { BookFormatEnum, BookStatusEnum, ImportSourceEnum } from './enums'

export const AwardType = builder.objectRef<{ name: string; year?: number }>('Award').implement({
  description: 'Literary award received by a book',
  fields: (t) => ({
    name: t.exposeString('name', { description: 'Award name' }),
    year: t.exposeInt('year', { nullable: true, description: 'Year awarded' }),
  }),
})

export const PublicRatingRef = builder.objectRef<PublicRatingType>('PublicRating').implement({
  description: 'Community rating from an external platform',
  fields: (t) => ({
    source: t.exposeString('source', {
      description: 'Platform name (e.g. Hardcover, Goodreads)',
    }),
    score: t.field({
      type: 'Note',
      description: 'Score received',
      resolve: ({ score }) => score,
    }),
    maxScore: t.field({
      type: 'Note',
      description: 'Maximum possible score',
      resolve: ({ maxScore }) => maxScore,
    }),
    voterCount: t.exposeInt('voterCount', { description: 'Number of voters' }),
    url: t.field({
      type: 'Url',
      description: 'Link to the book page on the platform',
      resolve: ({ url }) => url,
    }),
  }),
})

export const BookType = builder.objectRef<Book>('Book').implement({
  description: 'A book in the personal library',
  fields: (t) => ({
    id: t.field({
      type: 'BookId',
      description: 'Unique identifier',
      resolve: ({ id }) => id,
    }),
    title: t.field({
      type: 'BookTitle',
      description: 'Book title',
      resolve: ({ title }) => title,
    }),
    authors: t.field({
      type: ['PersonName'],
      description: 'Book authors',
      resolve: ({ authors }) => authors,
    }),
    publisher: t.field({
      type: 'Publisher',
      nullable: true,
      description: 'Publisher',
      resolve: ({ publisher }) => publisher ?? null,
    }),
    publishedDate: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Publication date',
      resolve: ({ publishedDate }) => publishedDate ?? null,
    }),
    pageCount: t.field({
      type: 'PageCount',
      nullable: true,
      description: 'Page count',
      resolve: ({ pageCount }) => pageCount ?? null,
    }),
    genre: t.field({
      type: 'Genre',
      nullable: true,
      description: 'Literary genre (e.g. Romance, Sci-Fi, Thriller)',
      resolve: ({ genre }) => genre ?? null,
    }),
    synopsis: t.exposeString('synopsis', { nullable: true, description: 'Book synopsis' }),
    isbn: t.field({
      type: 'ISBN',
      nullable: true,
      description: 'ISBN number',
      resolve: ({ isbn }) => isbn ?? null,
    }),
    language: t.field({
      type: 'Language',
      nullable: true,
      description: 'Book language (e.g. fr, en)',
      resolve: ({ language }) => language ?? null,
    }),
    format: t.field({
      type: BookFormatEnum,
      nullable: true,
      description: 'Book format',
      resolve: ({ format }) => format ?? null,
    }),
    translator: t.field({
      type: 'PersonName',
      nullable: true,
      description: 'Translator',
      resolve: ({ translator }) => translator ?? null,
    }),
    estimatedPrice: t.field({
      type: 'Eur',
      nullable: true,
      description: 'Estimated price in euros',
      resolve: ({ estimatedPrice }) => estimatedPrice ?? null,
    }),
    duration: t.exposeString('duration', { nullable: true, description: 'Duration (audiobook)' }),
    narrators: t.field({
      type: ['PersonName'],
      description: 'Narrators (audiobook)',
      resolve: ({ narrators }) => narrators,
    }),
    personalNotes: t.exposeString('personalNotes', {
      nullable: true,
      description: 'Personal notes',
    }),
    status: t.field({
      type: BookStatusEnum,
      description: 'Reading status',
      resolve: ({ status }) => status,
    }),
    readDate: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Read date',
      resolve: ({ readDate }) => readDate ?? null,
    }),
    awards: t.field({
      type: [AwardType],
      description: 'Literary awards',
      resolve: ({ awards }) => awards,
    }),
    publicRatings: t.field({
      type: [PublicRatingRef],
      description: 'Community ratings',
      resolve: ({ publicRatings }) => publicRatings,
    }),
    importSource: t.field({
      type: ImportSourceEnum,
      nullable: true,
      description: 'Import source',
      resolve: ({ importSource }) => importSource ?? null,
    }),
    externalUrl: t.field({
      type: 'Url',
      nullable: true,
      description: 'External URL (Audible, etc.)',
      resolve: ({ externalUrl }) => externalUrl ?? null,
    }),
    createdAt: t.field({
      type: 'DateTime',
      description: 'Date added to library',
      resolve: ({ createdAt }) => createdAt,
    }),
    updatedAt: t.field({
      type: 'DateTime',
      description: 'Last modified date',
      resolve: ({ updatedAt }) => updatedAt,
    }),
  }),
})
