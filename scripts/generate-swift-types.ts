type JSONSchema = {
  type?: string
  format?: string
  properties?: Record<string, JSONSchema>
  required?: string[]
  items?: JSONSchema
  additionalProperties?: boolean
  $schema?: string
  minimum?: number
  maximum?: number
  pattern?: string
  anyOf?: JSONSchema[]
}

type SchemaMap = Record<string, JSONSchema>

const KNOWN_TYPES: Record<string, string> = {}

const resolveNullable = (schema: JSONSchema): { inner: JSONSchema; nullable: boolean } => {
  if (!schema.anyOf) return { inner: schema, nullable: false }
  const nonNull = schema.anyOf.filter(({ type }) => type !== 'null')
  if (nonNull.length === 1 && schema.anyOf.length - nonNull.length === 1) {
    return { inner: nonNull[0], nullable: true }
  }
  return { inner: schema, nullable: false }
}

const swiftType = (schema: JSONSchema, propertyName: string, parentName: string): string => {
  const { inner, nullable } = resolveNullable(schema)
  if (nullable) {
    const baseType = swiftType(inner, propertyName, parentName)
    return `${baseType}?`
  }
  if (inner.type === 'string' && inner.format === 'date-time') return 'Date'
  if (inner.type === 'string') return 'String'
  if (inner.type === 'integer') return 'Int'
  if (inner.type === 'number') return 'Double'
  if (inner.type === 'boolean') return 'Bool'
  if (inner.type === 'array' && inner.items) {
    const itemType = swiftType(inner.items, propertyName, parentName)
    return `[${itemType}]`
  }
  if (inner.type === 'object' && inner.properties) {
    const nestedName = inferNestedTypeName(propertyName, parentName)
    return nestedName
  }
  return 'Any'
}

const inferNestedTypeName = (propertyName: string, parentName: string): string => {
  const capitalized = propertyName.charAt(0).toUpperCase() + propertyName.slice(1)
  const knownKey = `${parentName}.${propertyName}`
  return KNOWN_TYPES[knownKey] ?? capitalized
}

const collectNestedTypes = (
  schema: JSONSchema,
  parentName: string,
  collected: { name: string; schema: JSONSchema }[],
) => {
  if (!schema.properties) return

  for (const [propName, propSchema] of Object.entries(schema.properties)) {
    if (propSchema.type === 'object' && propSchema.properties) {
      const nestedName = inferNestedTypeName(propName, parentName)
      collected.push({ name: nestedName, schema: propSchema })
      collectNestedTypes(propSchema, nestedName, collected)
    }
    if (
      propSchema.type === 'array' &&
      propSchema.items?.type === 'object' &&
      propSchema.items.properties
    ) {
      const nestedName = inferNestedTypeName(propName, parentName)
      collected.push({ name: nestedName, schema: propSchema.items })
      collectNestedTypes(propSchema.items, nestedName, collected)
    }
  }
}

const generateStruct = (name: string, schema: JSONSchema): string => {
  const required = new Set(schema.required ?? [])
  const properties = schema.properties ?? {}
  const hasId = 'id' in properties && properties.id.type === 'string'

  const protocols = hasId ? 'Decodable, Identifiable, Sendable' : 'Decodable, Sendable'

  const fields = Object.entries(properties).map(([propName, propSchema]) => {
    const type = swiftType(propSchema, propName, name)
    const isRequired = required.has(propName)
    const isNullable = type.endsWith('?')
    const isOptional = !isRequired || isNullable
    const keyword = isOptional ? 'var' : 'let'
    const typeAnnotation = isRequired ? type : `${type}?`
    return `    ${keyword} ${propName}: ${typeAnnotation}`
  })

  return `struct ${name}: ${protocols} {\n${fields.join('\n')}\n}`
}

const run = async () => {
  const schemasJson = await Bun.file('shared/api-schemas.json').text()
  const schemas: SchemaMap = JSON.parse(schemasJson)

  // Register all top-level types so nested references resolve correctly
  for (const name of Object.keys(schemas)) {
    const schema = schemas[name]
    if (!schema.properties) continue
    for (const [propName, propSchema] of Object.entries(schema.properties)) {
      if (propSchema.type === 'object' && propSchema.properties) {
        // Check if this nested shape matches a known top-level schema
        const matchingTopLevel = findMatchingTopLevel(propSchema, schemas)
        if (matchingTopLevel) {
          KNOWN_TYPES[`${name}.${propName}`] = matchingTopLevel
        }
      }
      if (
        propSchema.type === 'array' &&
        propSchema.items?.type === 'object' &&
        propSchema.items.properties
      ) {
        const matchingTopLevel = findMatchingTopLevel(propSchema.items, schemas)
        if (matchingTopLevel) {
          KNOWN_TYPES[`${name}.${propName}`] = matchingTopLevel
        }
      }
    }
  }

  // Collect all structs (top-level + nested inlined types not matching a top-level)
  const generated = new Map<string, string>()

  for (const [name, schema] of Object.entries(schemas)) {
    generated.set(name, generateStruct(name, schema))

    const nested: { name: string; schema: JSONSchema }[] = []
    collectNestedTypes(schema, name, nested)

    for (const { name: nestedName, schema: nestedSchema } of nested) {
      if (!generated.has(nestedName)) {
        generated.set(nestedName, generateStruct(nestedName, nestedSchema))
      }
    }
  }

  const header = [
    '// Auto-generated from API schemas — do not edit manually',
    '// Run `bun run generate` to regenerate',
    '',
    'import Foundation',
    '',
    '',
  ].join('\n')

  const output = `${header}${[...generated.values()].join('\n\n')}\n`

  await Bun.write('ios/Pchook/Generated/APITypes.swift', output)
  console.log(`Generated ${generated.size} Swift types to ios/Pchook/Generated/APITypes.swift`)
}

const findMatchingTopLevel = (schema: JSONSchema, allSchemas: SchemaMap): string | undefined => {
  const schemaProps = Object.keys(schema.properties ?? {})
    .sort()
    .join(',')
  for (const [name, topSchema] of Object.entries(allSchemas)) {
    const topProps = Object.keys(topSchema.properties ?? {})
      .sort()
      .join(',')
    if (schemaProps === topProps) return name
  }
  return undefined
}

run()
