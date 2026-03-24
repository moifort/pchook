import { printSchema } from 'graphql'
import { schema } from '~/graphql/schema'

const sdl = printSchema(schema)
await Bun.write('shared/schema.graphql', sdl)

process.stdout.write(`Exported GraphQL schema to shared/schema.graphql\n`)
