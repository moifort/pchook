import { expect, mock } from 'bun:test'
import type { AudibleCredentials } from '~/domain/audible/types'

const VALID_SESSION = '11111111-1111-1111-8111-111111111111'
const UNKNOWN_SESSION = '22222222-2222-2222-8222-222222222222'
const NO_CODE_SESSION = '33333333-3333-3333-8333-333333333333'

const fakeCredentials: AudibleCredentials = {
  accessToken: 'fake-access-token',
  refreshToken: 'fake-refresh-token',
  adpToken: 'fake-adp-token',
  devicePrivateKey: 'fake-private-key',
  serial: 'FAKESERIALNUMBER1234567890ABCDEF',
  locale: 'fr',
  expiresAt: new Date(Date.now() + 3600 * 1000),
}

const { AudibleCommand: AudibleCmd } = await import('~/domain/audible/command')

mock.module('~/domain/audible/audible.api', () => ({
  generateLoginUrl: async () => ({
    loginUrl: 'https://www.amazon.fr/ap/signin?test=1',
    sessionId: 'test-session-id',
    cookies: [],
  }),
  registerDevice: async (_code: string, sessionId: string) => {
    if (sessionId === UNKNOWN_SESSION) return 'session-not-found' as const
    await AudibleCmd.saveCredentials(fakeCredentials)
    return fakeCredentials
  },
  fetchLibrary: async (credentials: AudibleCredentials) => ({ items: [], credentials }),
  fetchWishlist: async (credentials: AudibleCredentials) => ({ items: [], credentials }),
  refreshAccessToken: async (credentials: AudibleCredentials) => credentials,
}))

import { AudibleCommand } from '~/domain/audible/command'
import { AudibleQuery } from '~/domain/audible/query'
import callbackHandler from '~/routes/audible/auth/callback.post'
import startHandler from '~/routes/audible/auth/start.get'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('Audible Auth Flow', () => {
  scenario('GET /audible/auth/start returns login URL', async () => {
    given('no credentials exist')

    when('GET /audible/auth/start is called with locale fr')
    const event = mockEvent({ query: { locale: 'fr' } })
    const result = await startHandler(event as never)

    then('a login URL and session ID are returned')
    expect(result.status).toBe(200)
    expect(result.data.loginUrl).toContain('amazon.fr')
    expect(result.data.sessionId).toBeString()
    expect(result.data.cookies).toBeArray()
  })

  scenario('POST /audible/auth/callback with valid session stores credentials', async () => {
    given('an auth session exists')
    await AudibleCommand.saveAuthSession(VALID_SESSION, {
      codeVerifier: 'test-verifier',
      serial: 'TESTSERIALNUMBER',
      locale: 'fr',
      createdAt: new Date(),
    })

    when('POST /audible/auth/callback is called with a redirect URL containing an auth code')
    const event = mockEvent({
      body: {
        sessionId: VALID_SESSION,
        redirectUrl:
          'https://www.amazon.fr/ap/maplanding?openid.oa2.authorization_code=AUTH_CODE_123',
      },
    })
    const result = await callbackHandler(event as never)

    then('credentials are stored successfully')
    expect(result.status).toBe(200)
    expect(result.data.success).toBe(true)

    and('the auth session is consumed')
    const hasCredentials = await AudibleQuery.hasCredentials()
    expect(hasCredentials).toBe(true)
  })

  scenario('POST /audible/auth/callback with unknown session returns 404', async () => {
    given('no auth session exists for the given ID')

    when('POST /audible/auth/callback is called with an unknown session')
    const event = mockEvent({
      body: {
        sessionId: UNKNOWN_SESSION,
        redirectUrl:
          'https://www.amazon.fr/ap/maplanding?openid.oa2.authorization_code=AUTH_CODE_123',
      },
    })

    then('it throws a 404 error')
    try {
      await callbackHandler(event as never)
      expect(true).toBe(false)
    } catch (error: unknown) {
      expect((error as { statusCode: number }).statusCode).toBe(404)
    }
  })

  scenario('POST /audible/auth/callback without auth code returns 400', async () => {
    given('an auth session exists')
    await AudibleCommand.saveAuthSession(NO_CODE_SESSION, {
      codeVerifier: 'test-verifier',
      serial: 'TESTSERIALNUMBER',
      locale: 'fr',
      createdAt: new Date(),
    })

    when('POST /audible/auth/callback is called without authorization code in URL')
    const event = mockEvent({
      body: {
        sessionId: NO_CODE_SESSION,
        redirectUrl: 'https://www.amazon.fr/ap/maplanding?error=access_denied',
      },
    })

    then('it throws a 400 error')
    try {
      await callbackHandler(event as never)
      expect(true).toBe(false)
    } catch (error: unknown) {
      expect((error as { statusCode: number }).statusCode).toBe(400)
    }
  })
})
