import { builder } from '~/domain/shared/graphql/builder'
import { BookFormatEnum, BookStatusEnum } from './enums'

const AwardInput = builder.inputType('AwardInput', {
  description: 'Literary award',
  fields: (t) => ({
    name: t.string({ required: true, description: 'Award name' }),
    year: t.int({ description: 'Year awarded' }),
  }),
})

const PublicRatingInput = builder.inputType('PublicRatingInput', {
  description: 'External community rating',
  fields: (t) => ({
    source: t.string({ required: true, description: 'Platform name' }),
    score: t.float({ required: true, description: 'Score received' }),
    maxScore: t.float({ required: true, description: 'Maximum possible score' }),
    voterCount: t.int({ required: true, description: 'Number of voters' }),
    url: t.string({ required: true, description: 'URL of the book page' }),
  }),
})

export const UpdateBookInput = builder.inputType('UpdateBookInput', {
  description: 'Editable book fields (all optional)',
  fields: (t) => ({
    title: t.string({ description: 'Book title' }),
    authors: t.stringList({ description: 'Authors' }),
    publisher: t.string({ description: 'Publisher (null to remove)' }),
    publishedDate: t.string({ description: 'Publication date (ISO 8601)' }),
    pageCount: t.int({ description: 'Page count (null to remove)' }),
    genre: t.string({ description: 'Literary genre (null to remove)' }),
    synopsis: t.string({ description: 'Synopsis' }),
    isbn: t.string({ description: 'ISBN number (null to remove)' }),
    language: t.string({ description: 'Language (e.g. fr, en)' }),
    format: t.field({ type: BookFormatEnum, description: 'Book format' }),
    translator: t.string({ description: 'Translator (null to remove)' }),
    estimatedPrice: t.float({ description: 'Estimated price in euros (null to remove)' }),
    duration: t.string({ description: 'Duration (audiobook)' }),
    narrators: t.stringList({ description: 'Narrators (audiobook)' }),
    personalNotes: t.string({ description: 'Personal notes' }),
    status: t.field({ type: BookStatusEnum, description: 'Reading status' }),
    readDate: t.string({ description: 'Read date (ISO 8601)' }),
    awards: t.field({ type: [AwardInput], description: 'Literary awards' }),
    publicRatings: t.field({ type: [PublicRatingInput], description: 'Community ratings' }),
    series: t.string({ description: 'Series name (null to remove from series)' }),
    seriesLabel: t.string({ description: 'Label in series' }),
    seriesNumber: t.float({ description: 'Position in series' }),
  }),
})
