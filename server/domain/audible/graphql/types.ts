import { builder } from '~/domain/shared/graphql/builder'

type AuthStartData = {
  loginUrl: string
  sessionId: string
  cookies: { name: string; value: string; domain: string }[]
}

const AuthCookieType = builder
  .objectRef<{ name: string; value: string; domain: string }>('AuthCookie')
  .implement({
    description: "Cookie d'authentification Audible",
    fields: (t) => ({
      name: t.exposeString('name', { description: 'Nom du cookie' }),
      value: t.exposeString('value', { description: 'Valeur du cookie' }),
      domain: t.exposeString('domain', { description: 'Domaine du cookie' }),
    }),
  })

export const AuthStartResponseType = builder
  .objectRef<AuthStartData>('AuthStartResponse')
  .implement({
    description: "Réponse de démarrage de l'authentification Audible",
    fields: (t) => ({
      loginUrl: t.exposeString('loginUrl', { description: 'URL de connexion Audible' }),
      sessionId: t.exposeString('sessionId', {
        description: "Identifiant de session d'authentification",
      }),
      cookies: t.field({
        type: [AuthCookieType],
        description: 'Cookies à envoyer avec la requête de connexion',
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
  description: "Statut de l'intégration Audible",
  fields: (t) => ({
    connected: t.exposeBoolean('connected', { description: 'Credentials configurées' }),
    fetchInProgress: t.exposeBoolean('fetchInProgress', { description: 'Fetch en cours' }),
    libraryCount: t.exposeInt('libraryCount', {
      description: 'Nombre de livres dans la bibliothèque',
    }),
    wishlistCount: t.exposeInt('wishlistCount', {
      description: 'Nombre de livres dans la wishlist',
    }),
    lastSyncAt: t.string({
      nullable: true,
      description: 'Dernière synchronisation (ISO 8601)',
      resolve: ({ lastSyncAt }) => lastSyncAt?.toISOString() ?? null,
    }),
    lastFetchedAt: t.string({
      nullable: true,
      description: 'Dernier fetch (ISO 8601)',
      resolve: ({ lastFetchedAt }) => lastFetchedAt?.toISOString() ?? null,
    }),
    rawItemCount: t.exposeInt('rawItemCount', { description: "Nombre d'éléments bruts" }),
    importTaskId: t.exposeString('importTaskId', {
      description: 'Identifier of the Audible import task (use task query to get state)',
    }),
  }),
})
