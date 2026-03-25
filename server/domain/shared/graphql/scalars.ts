import { GraphQLError } from 'graphql'
import { ZodError } from 'zod'
import {
  BookId,
  BookStatus,
  BookTitle,
  Genre,
  ISBN,
  Note,
  PageCount,
  Publisher,
  RatingScore,
} from '~/domain/book/primitives'
import { SeriesLabel, SeriesName, SeriesPosition } from '~/domain/series/primitives'
import { Eur, PersonName, Url } from '~/domain/shared/primitives'
import { builder } from './builder'

const validatedParse =
  <T>(name: string, parse: (value: unknown) => T) =>
  (value: unknown): T => {
    try {
      return parse(value)
    } catch (error) {
      const message =
        error instanceof ZodError
          ? error.issues.map(({ message }) => message).join(', ')
          : `Invalid ${name}`
      throw new GraphQLError(`Invalid value for ${name}: ${message}`, {
        extensions: { code: 'BAD_USER_INPUT' },
      })
    }
  }

// Book domain — string-based
builder.scalarType('BookId', {
  description: 'Book unique identifier (UUID)',
  serialize: (value) => String(value),
  parseValue: validatedParse('BookId', BookId),
})

builder.scalarType('BookStatus', {
  description: 'Reading status (to-read | read)',
  serialize: (value) => value as string,
  parseValue: validatedParse('BookStatus', BookStatus),
})

builder.scalarType('BookTitle', {
  description: 'Book title (non-empty)',
  serialize: (value) => String(value),
  parseValue: validatedParse('BookTitle', BookTitle),
})

builder.scalarType('Publisher', {
  description: 'Publisher name (non-empty)',
  serialize: (value) => String(value),
  parseValue: validatedParse('Publisher', Publisher),
})

builder.scalarType('Genre', {
  description: 'Literary genre (non-empty)',
  serialize: (value) => String(value),
  parseValue: validatedParse('Genre', Genre),
})

builder.scalarType('ISBN', {
  description: 'ISBN number (10-17 characters)',
  serialize: (value) => String(value),
  parseValue: validatedParse('ISBN', ISBN),
})

// Book domain — number-based
builder.scalarType('PageCount', {
  description: 'Page count (positive integer)',
  serialize: (value) => Number(value),
  parseValue: validatedParse('PageCount', PageCount),
})

builder.scalarType('Note', {
  description: 'Personal rating score (integer 0-5)',
  serialize: (value) => Number(value),
  parseValue: validatedParse('Note', Note),
})

builder.scalarType('RatingScore', {
  description: 'Community rating score (decimal 0-10)',
  serialize: (value) => Number(value),
  parseValue: validatedParse('RatingScore', RatingScore),
})

// Shared domain
builder.scalarType('Eur', {
  description: 'Price in euros (non-negative number)',
  serialize: (value) => Number(value),
  parseValue: validatedParse('Eur', Eur),
})

builder.scalarType('PersonName', {
  description: 'Person name (1-200 characters)',
  serialize: (value) => String(value),
  parseValue: validatedParse('PersonName', PersonName),
})

builder.scalarType('Url', {
  description: 'Valid URL',
  serialize: (value) => String(value),
  parseValue: validatedParse('Url', Url),
})

// Series domain
builder.scalarType('SeriesName', {
  description: 'Series name (non-empty)',
  serialize: (value) => String(value),
  parseValue: validatedParse('SeriesName', SeriesName),
})

builder.scalarType('SeriesLabel', {
  description: 'Label in series (non-empty)',
  serialize: (value) => String(value),
  parseValue: validatedParse('SeriesLabel', SeriesLabel),
})

builder.scalarType('SeriesPosition', {
  description: 'Position in series (positive number)',
  serialize: (value) => Number(value),
  parseValue: validatedParse('SeriesPosition', SeriesPosition),
})

// Audible domain
import { Asin, AudibleSource, AudibleSyncStatus } from '~/domain/provider/audible/primitives'

builder.scalarType('Asin', {
  description: 'Amazon Standard Identification Number (10 alphanumeric characters)',
  serialize: (value) => String(value),
  parseValue: validatedParse('Asin', Asin),
})

builder.scalarType('AudibleSyncStatus', {
  description: 'Audible sync status (disconnected | connected | fetching | fetched)',
  serialize: (value) => String(value),
  parseValue: validatedParse('AudibleSyncStatus', AudibleSyncStatus),
})

builder.scalarType('AudibleSource', {
  description: 'Audible item source (library | wishlist)',
  serialize: (value) => String(value),
  parseValue: validatedParse('AudibleSource', AudibleSource),
})
