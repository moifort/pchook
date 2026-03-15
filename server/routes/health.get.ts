export default defineEventHandler(() => {
  return { status: 200, data: 'ok' } as const
})
