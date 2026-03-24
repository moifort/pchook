import { builder } from '~/domain/shared/graphql/builder'

type AuthStartData = {
  loginUrl: string
  sessionId: string
  cookies: { name: string; value: string; domain: string }[]
}

const AuthCookieType = builder
  .objectRef<{ name: string; value: string; domain: string }>('AuthCookie')
  .implement({
    description: 'Audible authentication cookie',
    fields: (t) => ({
      name: t.exposeString('name', { description: 'Cookie name' }),
      value: t.exposeString('value', { description: 'Cookie value' }),
      domain: t.exposeString('domain', { description: 'Cookie domain' }),
    }),
  })

export const AuthStartResponseType = builder
  .objectRef<AuthStartData>('AuthStartResponse')
  .implement({
    description: 'Audible authentication start response',
    fields: (t) => ({
      loginUrl: t.exposeString('loginUrl', { description: 'Audible login URL' }),
      sessionId: t.exposeString('sessionId', {
        description: 'Authentication session identifier',
      }),
      cookies: t.field({
        type: [AuthCookieType],
        description: 'Cookies to send with the login request',
        resolve: ({ cookies }) => cookies,
      }),
    }),
  })

type AudibleStatusData = {
  connected: boolean
  fetchInProgress: boolean
  libraryCount: number
  wishlistCount: number
  lastSyncAt?: Date
  lastFetchedAt?: Date
  rawItemCount: number
  importTaskId: string
}

export const AudibleStatusType = builder.objectRef<AudibleStatusData>('AudibleStatus').implement({
  description: 'Audible integration status',
  fields: (t) => ({
    connected: t.exposeBoolean('connected', { description: 'Credentials configured' }),
    fetchInProgress: t.exposeBoolean('fetchInProgress', { description: 'Fetch in progress' }),
    libraryCount: t.exposeInt('libraryCount', {
      description: 'Number of books in the library',
    }),
    wishlistCount: t.exposeInt('wishlistCount', {
      description: 'Number of books in the wishlist',
    }),
    lastSyncAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Last sync date',
      resolve: ({ lastSyncAt }) => lastSyncAt ?? null,
    }),
    lastFetchedAt: t.field({
      type: 'DateTime',
      nullable: true,
      description: 'Last fetch date',
      resolve: ({ lastFetchedAt }) => lastFetchedAt ?? null,
    }),
    rawItemCount: t.exposeInt('rawItemCount', { description: 'Number of raw items' }),
    importTaskId: t.exposeString('importTaskId', {
      description: 'Identifier of the Audible import task (use task query to get state)',
    }),
  }),
})
