import { z } from 'zod'
import { registerDevice } from '~/domain/audible/audible.api'

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const sessionId = z.string().uuid().parse(body.sessionId)
  const redirectUrl = z.string().url().parse(body.redirectUrl)

  const url = new URL(redirectUrl)
  const authorizationCode = url.searchParams.get('openid.oa2.authorization_code')
  if (!authorizationCode) {
    throw createError({ statusCode: 400, statusMessage: 'Missing authorization code in URL' })
  }

  const result = await registerDevice(authorizationCode, sessionId)
  if (result === 'session-not-found') {
    throw createError({ statusCode: 404, statusMessage: 'Auth session not found or expired' })
  }

  return { status: 200, data: { success: true } } as const
})
