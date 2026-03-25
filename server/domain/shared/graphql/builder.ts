import SchemaBuilder from '@pothos/core'
import { GraphQLScalarType } from 'graphql'
import type { H3Event } from 'h3'
import type {
  BookId,
  BookStatus,
  BookTitle,
  Genre,
  ISBN,
  Note,
  PageCount,
  Publisher,
  RatingScore,
} from '~/domain/book/types'
import type { Asin, AudibleSource, AudibleSyncStatus } from '~/domain/provider/audible/types'
import type { SeriesLabel, SeriesName, SeriesPosition } from '~/domain/series/types'
import type { Eur, PersonName, Url } from '~/domain/shared/types'

export type GraphQLContext = {
  event: H3Event
}

const DateTimeScalar = new GraphQLScalarType({
  name: 'DateTime',
  description: 'ISO 8601 date-time string',
  serialize: (value: unknown) => (value instanceof Date ? value.toISOString() : value),
  parseValue: (value: unknown) => new Date(value as string),
})

export const builder = new SchemaBuilder<{
  Context: GraphQLContext
  DefaultFieldNullability: false
  Scalars: {
    DateTime: { Input: Date; Output: Date }
    BookId: { Input: BookId; Output: BookId }
    BookStatus: { Input: BookStatus; Output: BookStatus }
    BookTitle: { Input: BookTitle; Output: BookTitle }
    Publisher: { Input: Publisher; Output: Publisher }
    Genre: { Input: Genre; Output: Genre }
    ISBN: { Input: ISBN; Output: ISBN }
    PageCount: { Input: PageCount; Output: PageCount }
    Note: { Input: Note; Output: Note }
    RatingScore: { Input: RatingScore; Output: RatingScore }
    Eur: { Input: Eur; Output: Eur }
    PersonName: { Input: PersonName; Output: PersonName }
    Url: { Input: Url; Output: Url }
    SeriesName: { Input: SeriesName; Output: SeriesName }
    SeriesLabel: { Input: SeriesLabel; Output: SeriesLabel }
    SeriesPosition: { Input: SeriesPosition; Output: SeriesPosition }
    Asin: { Input: Asin; Output: Asin }
    AudibleSyncStatus: { Input: AudibleSyncStatus; Output: AudibleSyncStatus }
    AudibleSource: { Input: AudibleSource; Output: AudibleSource }
  }
}>({
  defaultFieldNullability: false,
})

builder.addScalarType('DateTime', DateTimeScalar)
builder.queryType({})
builder.mutationType({})
