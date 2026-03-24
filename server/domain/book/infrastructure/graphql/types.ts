import type { BookListItem as BookListItemModel } from '~/domain/book/read-model/types'
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
    score: t.float({ description: 'Score received', resolve: ({ score }) => Number(score) }),
    maxScore: t.float({
      description: 'Maximum possible score',
      resolve: ({ maxScore }) => Number(maxScore),
    }),
    voterCount: t.exposeInt('voterCount', { description: 'Number of voters' }),
    url: t.string({
      description: 'Link to the book page on the platform',
      resolve: ({ url }) => String(url),
    }),
  }),
})

export const BookType = builder.objectRef<Book>('Book').implement({
  description: 'A book in the personal library',
  fields: (t) => ({
    id: t.id({ description: 'Unique identifier', resolve: ({ id }) => String(id) }),
    title: t.string({ description: 'Book title', resolve: ({ title }) => String(title) }),
    authors: t.stringList({
      description: 'Book authors',
      resolve: ({ authors }) => authors.map(String),
    }),
    publisher: t.string({
      nullable: true,
      description: 'Publisher',
      resolve: ({ publisher }) => (publisher ? String(publisher) : null),
    }),
    publishedDate: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Publication date',
      resolve: ({ publishedDate }) => publishedDate ?? null,
    }),
    pageCount: t.int({
      nullable: true,
      description: 'Page count',
      resolve: ({ pageCount }) => (pageCount ? Number(pageCount) : null),
    }),
    genre: t.string({
      nullable: true,
      description: 'Literary genre (e.g. Romance, Sci-Fi, Thriller)',
      resolve: ({ genre }) => (genre ? String(genre) : null),
    }),
    synopsis: t.exposeString('synopsis', { nullable: true, description: 'Book synopsis' }),
    isbn: t.string({
      nullable: true,
      description: 'ISBN number',
      resolve: ({ isbn }) => (isbn ? String(isbn) : null),
    }),
    language: t.string({
      nullable: true,
      description: 'Book language (e.g. fr, en)',
      resolve: ({ language }) => (language ? String(language) : null),
    }),
    format: t.field({
      type: BookFormatEnum,
      nullable: true,
      description: 'Book format',
      resolve: ({ format }) => format ?? null,
    }),
    translator: t.string({
      nullable: true,
      description: 'Translator',
      resolve: ({ translator }) => (translator ? String(translator) : null),
    }),
    estimatedPrice: t.float({
      nullable: true,
      description: 'Estimated price in euros',
      resolve: ({ estimatedPrice }) => (estimatedPrice ? Number(estimatedPrice) : null),
    }),
    duration: t.exposeString('duration', { nullable: true, description: 'Duration (audiobook)' }),
    narrators: t.stringList({
      description: 'Narrators (audiobook)',
      resolve: ({ narrators }) => narrators.map(String),
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
    externalUrl: t.string({
      nullable: true,
      description: 'External URL (Audible, etc.)',
      resolve: ({ externalUrl }) => (externalUrl ? String(externalUrl) : null),
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

export const BookListItemType = builder.objectRef<BookListItemModel>('BookListItem').implement({
  description: 'Book list item (summary view)',
  fields: (t) => ({
    id: t.id({ description: 'Unique identifier', resolve: ({ id }) => String(id) }),
    title: t.exposeString('title', { description: 'Book title' }),
    coverImageUrl: t.exposeString('coverImageUrl', {
      nullable: true,
      description: 'Cover image URL',
    }),
    authors: t.stringList({
      description: 'Authors',
      resolve: ({ authors }) => authors.map(String),
    }),
    genre: t.string({
      nullable: true,
      description: 'Literary genre',
      resolve: ({ genre }) => (genre ? String(genre) : null),
    }),
    status: t.field({
      type: BookStatusEnum,
      description: 'Reading status',
      resolve: ({ status }) => status,
    }),
    estimatedPrice: t.float({
      nullable: true,
      description: 'Estimated price in euros',
      resolve: ({ estimatedPrice }) => (estimatedPrice ? Number(estimatedPrice) : null),
    }),
    awards: t.field({
      type: [AwardType],
      description: 'Literary awards',
      resolve: ({ awards }) => awards,
    }),
    rating: t.int({
      nullable: true,
      description: 'Personal rating (0-10)',
      resolve: ({ rating }) => (rating ? Number(rating) : null),
    }),
    language: t.exposeString('language', { nullable: true, description: 'Language' }),
    seriesName: t.exposeString('seriesName', { nullable: true, description: 'Series name' }),
    seriesLabel: t.exposeString('seriesLabel', {
      nullable: true,
      description: 'Label in series (e.g. Volume 3)',
    }),
    seriesPosition: t.exposeInt('seriesPosition', {
      nullable: true,
      description: 'Position in series',
    }),
    createdAt: t.field({
      type: 'DateTime',
      description: 'Date added',
      resolve: ({ createdAt }) => createdAt,
    }),
  }),
})
