import SchemaBuilder from '@pothos/core'
import { GraphQLScalarType } from 'graphql'
import type { H3Event } from 'h3'

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
    DateTime: {
      Input: Date
      Output: Date
    }
  }
}>({
  defaultFieldNullability: false,
})

builder.addScalarType('DateTime', DateTimeScalar)
builder.queryType({})
builder.mutationType({})
