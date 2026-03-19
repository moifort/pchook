export default defineEventHandler(async () => {
  for (const name of [
    'books',
    'book-images',
    'series',
    'series-books',
    'reviews',
    'scan-cache',
    'migration-meta',
    'audible-credentials',
    'audible-mappings',
    'audible-auth-sessions',
  ]) {
    const storage = useStorage(name)
    const keys = await storage.getKeys()
    for (const key of keys) await storage.removeItem(key)
  }
  return { status: 200, data: 'Database reset' } as const
})
