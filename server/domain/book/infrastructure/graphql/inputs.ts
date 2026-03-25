import { builder } from '~/domain/shared/graphql/builder'
import { BookFormatEnum, LanguageEnum } from './enums'

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
    score: t.field({ type: 'RatingScore', required: true, description: 'Score received' }),
    maxScore: t.field({
      type: 'RatingScore',
      required: true,
      description: 'Maximum possible score',
    }),
    voterCount: t.int({ required: true, description: 'Number of voters' }),
    url: t.field({ type: 'Url', required: true, description: 'URL of the book page' }),
  }),
})

export const UpdateBookInput = builder.inputType('UpdateBookInput', {
  description: 'Editable book fields (all optional)',
  fields: (t) => ({
    title: t.field({ type: 'BookTitle', description: 'Book title' }),
    authors: t.field({ type: ['PersonName'], description: 'Authors' }),
    publisher: t.field({ type: 'Publisher', description: 'Publisher (null to remove)' }),
    publishedDate: t.string({ description: 'Publication date (ISO 8601)' }),
    pageCount: t.field({ type: 'PageCount', description: 'Page count (null to remove)' }),
    genre: t.field({ type: 'Genre', description: 'Literary genre (null to remove)' }),
    synopsis: t.string({ description: 'Synopsis' }),
    isbn: t.field({ type: 'ISBN', description: 'ISBN number (null to remove)' }),
    language: t.field({ type: LanguageEnum, description: 'Language (ISO 639-1)' }),
    format: t.field({ type: BookFormatEnum, description: 'Book format' }),
    translator: t.field({ type: 'PersonName', description: 'Translator (null to remove)' }),
    estimatedPrice: t.field({
      type: 'Eur',
      description: 'Estimated price in euros (null to remove)',
    }),
    durationMinutes: t.int({ description: 'Duration in minutes (audiobook)' }),
    narrators: t.field({ type: ['PersonName'], description: 'Narrators (audiobook)' }),
    personalNotes: t.string({ description: 'Personal notes' }),
    status: t.field({ type: 'BookStatus', description: 'Reading status' }),
    readDate: t.string({ description: 'Read date (ISO 8601)' }),
    awards: t.field({ type: [AwardInput], description: 'Literary awards' }),
    publicRatings: t.field({ type: [PublicRatingInput], description: 'Community ratings' }),
    series: t.field({
      type: 'SeriesName',
      description: 'Series name (null to remove from series)',
    }),
    seriesLabel: t.field({ type: 'SeriesLabel', description: 'Label in series' }),
    seriesNumber: t.field({ type: 'SeriesPosition', description: 'Position in series' }),
  }),
})
