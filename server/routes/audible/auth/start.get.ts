import { generateLoginUrl } from '~/domain/audible/audible.api'
import { AudibleLocale } from '~/domain/audible/primitives'

export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const locale = AudibleLocale(query.locale ?? 'fr')
  const result = await generateLoginUrl(locale)
  return { status: 200, data: result } as const
})
