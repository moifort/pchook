import SchemaBuilder from '@pothos/core'
import type { GraphQLContext } from './context'

export const builder = new SchemaBuilder<{ Context: GraphQLContext }>({})

builder.queryType({})
builder.mutationType({})
