import { randomUUID } from 'node:crypto'
import {
  type AudibleItem as LibAudibleItem,
  library,
  login,
  refresh,
  register,
  verify,
  wishlist,
} from 'audible-api-ts'
import { AudibleCommand } from '~/domain/provider/audible/command'
import { Asin } from '~/domain/provider/audible/primitives'
import type {
  AudibleCredentials,
  AudibleItem,
  AudibleLocale,
} from '~/domain/provider/audible/types'
import { createLogger } from '~/system/logger'

const log = createLogger('audible-api')

const toDomainItem = (item: LibAudibleItem): AudibleItem => ({
  asin: Asin(item.asin),
  title: item.title,
  authors: item.authors,
  narrators: item.narrators,
  durationMinutes: item.durationMinutes,
  publisher: item.publisher,
  language: item.language,
  releaseDate: item.releaseDate,
  coverUrl: item.coverUrl,
  series: item.series,
  finishedAt: item.listeningStatus?.finishedAt,
})

export const generateLoginUrl = async (locale: AudibleLocale) => {
  const { loginUrl, session, cookies } = await login(locale)

  const sessionId = randomUUID()
  await AudibleCommand.saveAuthSession(sessionId, { ...session, createdAt: new Date() })

  log.info('Generated login URL', { locale, sessionId })

  return { loginUrl, sessionId, cookies } as const
}

export const registerDevice = async (authorizationCode: string, sessionId: string) => {
  const session = await AudibleCommand.consumeAuthSession(sessionId)
  if (session === 'not-found') return 'session-not-found' as const

  log.info('Registering device', { locale: session.locale })

  const credentials = await register(authorizationCode, session)
  await AudibleCommand.saveCredentials(credentials)

  log.info('Device registered successfully', { locale: session.locale })

  return credentials
}

export const refreshAccessToken = async (credentials: AudibleCredentials) => {
  log.info('Refreshing access token', { locale: credentials.locale })

  const updated = await refresh(credentials)
  await AudibleCommand.saveCredentials(updated)

  log.info('Access token refreshed', { locale: credentials.locale })

  return updated
}

export const fetchLibrary = async (credentials: AudibleCredentials) => {
  log.info('Fetching library', { locale: credentials.locale })
  const { items, credentials: updated } = await library(credentials)
  return { items: items.map(toDomainItem), credentials: updated }
}

export const fetchWishlist = async (credentials: AudibleCredentials) => {
  log.info('Fetching wishlist', { locale: credentials.locale })
  const { items, credentials: updated } = await wishlist(credentials)
  return { items: items.map(toDomainItem), credentials: updated }
}

export const verifyConnection = async (credentials: AudibleCredentials) => {
  log.info('Verifying Audible connection', { locale: credentials.locale })
  await verify(credentials)
}
