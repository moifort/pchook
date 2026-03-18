import { createHash, randomBytes, randomUUID } from 'node:crypto'
import { AudibleCommand } from '~/domain/audible/command'
import { Asin } from '~/domain/audible/primitives'
import type {
  AudibleCredentials,
  AudibleItem,
  AudibleLocale,
  AuthSession,
} from '~/domain/audible/types'
import { AUDIBLE_LOCALES } from '~/domain/audible/types'
import { createLogger } from '~/system/logger'

const log = createLogger('audible-api')

const DEVICE_TYPE = 'A2CZJZGLK2JJVM'
const APP_VERSION = '3.56.2'
const SOFTWARE_VERSION = '35602678'

const base64url = (buffer: Buffer) =>
  buffer.toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')

const base64nopad = (buffer: Buffer) => buffer.toString('base64').replace(/=+$/, '')

const toHexString = (input: string) => Buffer.from(input, 'utf-8').toString('hex')

// --- Auth: PKCE + Device Registration ---

export const generateLoginUrl = async (locale: AudibleLocale) => {
  const config = AUDIBLE_LOCALES[locale]

  const codeVerifier = base64url(randomBytes(32))
  const codeChallenge = base64url(createHash('sha256').update(codeVerifier).digest())

  const serial = randomUUID().replace(/-/g, '').toUpperCase()
  const clientId = toHexString(`${serial}#${DEVICE_TYPE}`)

  const sessionId = randomUUID()

  const session: AuthSession = {
    codeVerifier,
    serial,
    locale,
    createdAt: new Date(),
  }
  await AudibleCommand.saveAuthSession(sessionId, session)

  const params = new URLSearchParams({
    'openid.oa2.response_type': 'code',
    'openid.oa2.code_challenge_method': 'S256',
    'openid.oa2.code_challenge': codeChallenge,
    'openid.return_to': `https://www.amazon.${config.domain}/ap/maplanding`,
    'openid.assoc_handle': `amzn_audible_ios_${config.countryCode}`,
    'openid.identity': 'http://specs.openid.net/auth/2.0/identifier_select',
    pageId: 'amzn_audible_ios',
    accountStatusPolicy: 'P1',
    'openid.claimed_id': 'http://specs.openid.net/auth/2.0/identifier_select',
    'openid.mode': 'checkid_setup',
    'openid.ns.oa2': 'http://www.amazon.com/ap/ext/oauth/2',
    'openid.oa2.client_id': `device:${clientId}`,
    'openid.ns.pape': 'http://specs.openid.net/extensions/pape/1.0',
    marketPlaceId: config.marketplaceId,
    'openid.oa2.scope': 'device_auth_access',
    forceMobileLayout: 'true',
    'openid.ns': 'http://specs.openid.net/auth/2.0',
    'openid.pape.max_auth_age': '0',
  })

  const loginUrl = `https://www.amazon.${config.domain}/ap/signin?${params.toString()}`

  const cookies = [
    {
      name: 'frc',
      value: base64nopad(randomBytes(313)),
      domain: `.amazon.${config.domain}`,
    },
    {
      name: 'map-md',
      value: base64nopad(
        Buffer.from(
          JSON.stringify({
            device_user_dictionary: [],
            device_registration_data: { software_version: SOFTWARE_VERSION },
            app_identifier: { app_version: APP_VERSION, bundle_id: 'com.audible.iphone' },
          }),
        ),
      ),
      domain: `.amazon.${config.domain}`,
    },
    {
      name: 'amzn-app-id',
      value: 'MAPiOSLib/6.0/ToHideRetailLink',
      domain: `.amazon.${config.domain}`,
    },
  ]

  log.info('Generated login URL', { locale, sessionId })

  return { loginUrl, sessionId, cookies } as const
}

export const registerDevice = async (authorizationCode: string, sessionId: string) => {
  const session = await AudibleCommand.consumeAuthSession(sessionId)
  if (session === 'not-found') return 'session-not-found' as const

  const config = AUDIBLE_LOCALES[session.locale]
  const clientId = toHexString(`${session.serial}#${DEVICE_TYPE}`)

  const body = {
    requested_token_type: ['bearer', 'mac_dms', 'website_cookies', 'store_authentication_cookie'],
    cookies: { website_cookies: [], domain: `.amazon.${config.domain}` },
    registration_data: {
      domain: 'Device',
      app_version: APP_VERSION,
      device_serial: session.serial,
      device_type: DEVICE_TYPE,
      device_name:
        '%FIRST_NAME%%FIRST_NAME_POSSESSIVE_STRING%%DUPE_STRATEGY_1ST%Audible for iPhone',
      os_version: '15.0.0',
      software_version: SOFTWARE_VERSION,
      device_model: 'iPhone',
      app_name: 'Audible',
    },
    auth_data: {
      client_id: clientId,
      authorization_code: authorizationCode,
      code_verifier: session.codeVerifier,
      code_algorithm: 'SHA-256',
      client_domain: 'DeviceLegacy',
    },
    requested_extensions: ['device_info', 'customer_info'],
  }

  log.info('Registering device', { locale: session.locale })

  const response = await $fetch<{
    response: {
      success: {
        tokens: {
          bearer: { access_token: string; refresh_token: string; expires_in: string }
          mac_dms: { adp_token: string; device_private_key: string }
        }
      }
    }
  }>(`https://api.amazon.${config.domain}/auth/register`, {
    method: 'POST',
    body,
  })

  const bearer = response.response.success.tokens.bearer
  const macDms = response.response.success.tokens.mac_dms

  const credentials: AudibleCredentials = {
    accessToken: bearer.access_token,
    refreshToken: bearer.refresh_token,
    adpToken: macDms.adp_token,
    devicePrivateKey: macDms.device_private_key,
    serial: session.serial,
    locale: session.locale,
    expiresAt: new Date(Date.now() + Number(bearer.expires_in) * 1000),
  }

  await AudibleCommand.saveCredentials(credentials)

  log.info('Device registered successfully', { locale: session.locale })

  return credentials
}

// --- Token Refresh ---

export const refreshAccessToken = async (credentials: AudibleCredentials) => {
  const config = AUDIBLE_LOCALES[credentials.locale]

  log.info('Refreshing access token', { locale: credentials.locale })

  const response = await $fetch<{ access_token: string; expires_in: number }>(
    `https://api.amazon.${config.domain}/auth/token`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        app_name: 'Audible',
        app_version: APP_VERSION,
        source_token: credentials.refreshToken,
        requested_token_type: 'access_token',
        source_token_type: 'refresh_token',
      }).toString(),
    },
  )

  const updated: AudibleCredentials = {
    ...credentials,
    accessToken: response.access_token,
    expiresAt: new Date(Date.now() + response.expires_in * 1000),
  }

  await AudibleCommand.saveCredentials(updated)

  log.info('Access token refreshed', { locale: credentials.locale })

  return updated
}

// --- Library & Wishlist ---

const ensureValidToken = async (credentials: AudibleCredentials) => {
  const fiveMinutes = 5 * 60 * 1000
  if (new Date(credentials.expiresAt).getTime() - Date.now() < fiveMinutes) {
    return await refreshAccessToken(credentials)
  }
  return credentials
}

const audibleFetch = async <T>(
  path: string,
  credentials: AudibleCredentials,
  query?: Record<string, string>,
) => {
  const config = AUDIBLE_LOCALES[credentials.locale]
  const fresh = await ensureValidToken(credentials)

  try {
    const response = await $fetch<T>(`https://api.audible.${config.domain}/1.0${path}`, {
      headers: {
        Authorization: `Bearer ${fresh.accessToken}`,
        'client-id': toHexString(`${fresh.serial}#${DEVICE_TYPE}`),
      },
      query,
    })

    return { response, credentials: fresh }
  } catch (error: unknown) {
    const fetchError = error as { data?: unknown; status?: number }
    log.error('Audible API error', {
      path,
      status: fetchError.status,
      data: fetchError.data,
      query,
    })
    throw error
  }
}

type AudibleProductResponse = {
  items: {
    asin: string
    title: string
    authors?: { name: string }[]
    narrators?: { name: string }[]
    runtime_length_min?: number
    publisher_name?: string
    language?: string
    release_date?: string
    product_images?: Record<string, string>
    series?: { asin: string; title: string; sequence?: string }[]
  }[]
  total_results: number
}

const parseItems = (items: AudibleProductResponse['items']): AudibleItem[] =>
  items.map((item) => ({
    asin: Asin(item.asin),
    title: item.title,
    authors: (item.authors ?? []).map(({ name }) => name),
    narrators: (item.narrators ?? []).map(({ name }) => name),
    durationMinutes: item.runtime_length_min ?? 0,
    publisher: item.publisher_name,
    language: item.language,
    releaseDate: item.release_date ? new Date(item.release_date) : undefined,
    coverUrl: item.product_images?.['500'] ?? item.product_images?.['252'],
    series: item.series?.[0]
      ? {
          name: item.series[0].title,
          position: item.series[0].sequence ? Number(item.series[0].sequence) : undefined,
        }
      : undefined,
  }))

const RESPONSE_GROUPS = 'product_details,contributors,media,product_attrs'

const fetchPaginated = async (
  path: string,
  credentials: AudibleCredentials,
): Promise<{ items: AudibleItem[]; credentials: AudibleCredentials }> => {
  const allItems: AudibleItem[] = []
  const pageSize = 50
  let page = 1
  let totalResults = Infinity
  let currentCredentials = credentials

  while (allItems.length < totalResults) {
    const { response, credentials: updated } = await audibleFetch<AudibleProductResponse>(
      path,
      currentCredentials,
      {
        response_groups: RESPONSE_GROUPS,
        num_results: String(pageSize),
        page: String(page),
      },
    )

    currentCredentials = updated
    totalResults = response.total_results
    allItems.push(...parseItems(response.items))
    page += 1

    log.info(`Fetched page ${page - 1}`, { path, count: allItems.length, total: totalResults })
  }

  return { items: allItems, credentials: currentCredentials }
}

export const fetchLibrary = async (credentials: AudibleCredentials) => {
  log.info('Fetching library', { locale: credentials.locale })
  return fetchPaginated('/library', credentials)
}

export const fetchWishlist = async (credentials: AudibleCredentials) => {
  log.info('Fetching wishlist', { locale: credentials.locale })
  return fetchPaginated('/wishlist', credentials)
}
