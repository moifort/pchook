import SchemaBuilder from '@pothos/core'
import type { H3Event } from 'h3'

export type GraphQLContext = {
  event: H3Event
}

export const builder = new SchemaBuilder<{ Context: GraphQLContext }>({})

builder.queryType({})
builder.mutationType({})
