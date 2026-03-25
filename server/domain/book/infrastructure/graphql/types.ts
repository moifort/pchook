import type { Book, PublicRating as PublicRatingType } from '~/domain/book/types'
import { builder } from '~/domain/shared/graphql/builder'
import { BookFormatEnum, ImportSourceEnum, LanguageEnum } from './enums'

export const AwardType = builder.objectRef<{ name: string; year?: number }>('Award').implement({
  description: 'Literary award received by a book',
  fields: (t) => ({
    name: t.exposeString('name', {
      description: 'Short award name (e.g. "Prix Hugo", "Prix Goncourt")',
    }),
    year: t.exposeInt('year', { nullable: true, description: 'Year awarded (e.g. 2023)' }),
  }),
})

export const PublicRatingRef = builder.objectRef<PublicRatingType>('PublicRating').implement({
  description: 'Community rating from an external platform',
  fields: (t) => ({
    source: t.exposeString('source', {
      description: 'Platform name (e.g. Hardcover, Goodreads)',
    }),
    score: t.field({
      type: 'RatingScore',
      description: 'Score received (e.g. 3.75 out of 5)',
      resolve: ({ score }) => score,
    }),
    maxScore: t.field({
      type: 'RatingScore',
      description: 'Maximum possible score on this platform (e.g. 5, 10)',
      resolve: ({ maxScore }) => maxScore,
    }),
    voterCount: t.exposeInt('voterCount', {
      description: 'Number of voters who rated the book',
    }),
    url: t.field({
      type: 'Url',
      description: 'Direct link to the book page on the platform',
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
      description: 'Publisher (e.g. "Gallimard", "Folio"). Null if unknown',
      resolve: ({ publisher }) => publisher ?? null,
    }),
    publishedDate: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'First publication date. Null if unknown',
      resolve: ({ publishedDate }) => publishedDate ?? null,
    }),
    pageCount: t.field({
      type: 'PageCount',
      nullable: true,
      description: 'Number of pages. Null for audiobooks or if unknown',
      resolve: ({ pageCount }) => pageCount ?? null,
    }),
    genre: t.field({
      type: 'Genre',
      nullable: true,
      description: 'Literary genre, comma-separated if multiple (e.g. "LitRPG, Science Fantasy")',
      resolve: ({ genre }) => genre ?? null,
    }),
    synopsis: t.exposeString('synopsis', {
      nullable: true,
      description: 'Short summary of the book content (3-5 sentences)',
    }),
    isbn: t.field({
      type: 'ISBN',
      nullable: true,
      description: 'ISBN-13 or ISBN-10 (e.g. "978-2-07-036822-8"). Null if not available',
      resolve: ({ isbn }) => isbn ?? null,
    }),
    language: t.field({
      type: LanguageEnum,
      nullable: true,
      description: 'Book language as ISO 639-1 code. Null if unknown',
      resolve: ({ language }) => language ?? null,
    }),
    format: t.field({
      type: BookFormatEnum,
      nullable: true,
      description: 'Physical or digital format. Null if unknown',
      resolve: ({ format }) => format ?? null,
    }),
    translator: t.field({
      type: 'PersonName',
      nullable: true,
      description: 'Translator name, if the book is a translation. Null otherwise',
      resolve: ({ translator }) => translator ?? null,
    }),
    estimatedPrice: t.field({
      type: 'Eur',
      nullable: true,
      description: 'Estimated retail price in euros. Null if unknown',
      resolve: ({ estimatedPrice }) => estimatedPrice ?? null,
    }),
    durationMinutes: t.int({
      nullable: true,
      description: 'Duration in minutes for audiobooks (e.g. 510 for 8h30). Null for non-audio',
      resolve: ({ durationMinutes }) => durationMinutes ?? null,
    }),
    narrators: t.field({
      type: ['PersonName'],
      description: 'Audiobook narrators. Empty array for non-audio formats',
      resolve: ({ narrators }) => narrators,
    }),
    personalNotes: t.exposeString('personalNotes', {
      nullable: true,
      description: 'Free-form personal notes about the book',
    }),
    status: t.field({
      type: 'BookStatus',
      description: 'Reading status (to-read | read)',
      resolve: ({ status }) => status,
    }),
    readDate: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Date the book was finished reading. Null if not read yet',
      resolve: ({ readDate }) => readDate ?? null,
    }),
    awards: t.field({
      type: [AwardType],
      description: 'Literary awards received. Empty array if none',
      resolve: ({ awards }) => awards,
    }),
    publicRatings: t.field({
      type: [PublicRatingRef],
      description:
        'Community ratings from external platforms (Hardcover, Goodreads). Empty array if none',
      resolve: ({ publicRatings }) => publicRatings,
    }),
    importSource: t.field({
      type: ImportSourceEnum,
      nullable: true,
      description: 'How the book was added (scan, isbn, url, audible). Null if added manually',
      resolve: ({ importSource }) => importSource ?? null,
    }),
    externalUrl: t.field({
      type: 'Url',
      nullable: true,
      description: 'Link to the book on the import source (e.g. Audible page). Null if none',
      resolve: ({ externalUrl }) => externalUrl ?? null,
    }),
    createdAt: t.field({
      type: 'DateTime',
      description: 'Date the book was added to the library',
      resolve: ({ createdAt }) => createdAt,
    }),
    updatedAt: t.field({
      type: 'DateTime',
      description: 'Date of last modification',
      resolve: ({ updatedAt }) => updatedAt,
    }),
  }),
})
