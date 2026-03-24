import { GraphQLError } from 'graphql'
import { z } from 'zod'
import { generateLoginUrl, registerDevice } from '~/domain/audible/audible.api'
import { AudibleCommand } from '~/domain/audible/command'
import { AudibleLocale } from '~/domain/audible/primitives'
import { AudibleQuery } from '~/domain/audible/query'
import { AudibleUseCase, importRunner, importTaskDefinition } from '~/domain/audible/use-case'
import { builder } from '~/domain/shared/graphql/builder'
import { createLogger } from '~/system/logger'
import { AuthStartResponseType } from './types'

const log = createLogger('audible-graphql')

builder.mutationField('audibleAuthStart', (t) =>
  t.field({
    type: AuthStartResponseType,
    description: "Démarrer le flux d'authentification OAuth Audible",
    args: {
      locale: t.arg.string({ required: false, description: 'Locale Audible (par défaut: fr)' }),
    },
    resolve: async (_, { locale }) => {
      const audibleLocale = AudibleLocale(locale ?? 'fr')
      return await generateLoginUrl(audibleLocale)
    },
  }),
)

builder.mutationField('audibleAuthCallback', (t) =>
  t.field({
    type: 'Boolean',
    description: "Finaliser l'authentification OAuth Audible",
    args: {
      sessionId: t.arg.string({ required: true, description: 'Identifiant de session' }),
      redirectUrl: t.arg.string({ required: true, description: 'URL de redirection avec le code' }),
    },
    resolve: async (_, { sessionId, redirectUrl }) => {
      const validSessionId = z.string().uuid().parse(sessionId)
      const validUrl = z.string().url().parse(redirectUrl)

      const url = new URL(validUrl)
      const authorizationCode = url.searchParams.get('openid.oa2.authorization_code')
      if (!authorizationCode) {
        throw new GraphQLError('Missing authorization code in URL', {
          extensions: { code: 'BAD_REQUEST' },
        })
      }

      const result = await registerDevice(authorizationCode, validSessionId)
      if (result === 'session-not-found') {
        throw new GraphQLError('Auth session not found or expired', {
          extensions: { code: 'NOT_FOUND' },
        })
      }

      return true
    },
  }),
)

builder.mutationField('audibleDisconnect', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Déconnecter le compte Audible et nettoyer les données',
    resolve: async () => {
      await importRunner.reset()
      await AudibleCommand.removeCredentials()
      await AudibleCommand.clearRawItems()
      await AudibleCommand.clearMappings()
      return true
    },
  }),
)

builder.mutationField('audibleSyncFetch', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Récupérer la bibliothèque et wishlist Audible (tâche de fond)',
    resolve: async () => {
      const credentials = await AudibleQuery.getCredentials()
      if (!credentials) {
        throw new GraphQLError('Audible credentials not configured', {
          extensions: { code: 'PRECONDITION_FAILED' },
        })
      }

      if (AudibleQuery.isFetchInProgress()) {
        throw new GraphQLError('Fetch already in progress', {
          extensions: { code: 'CONFLICT' },
        })
      }

      AudibleUseCase.fetchAndStore().catch((error) => {
        log.error('Background fetch failed', { error: String(error) })
      })

      return true
    },
  }),
)

builder.mutationField('audibleSyncVerify', (t) =>
  t.field({
    type: 'Boolean',
    description: 'Vérifier la validité des credentials Audible',
    resolve: async () => {
      const result = await AudibleUseCase.verify()
      if (result === 'no-credentials') {
        throw new GraphQLError('Audible credentials not configured', {
          extensions: { code: 'PRECONDITION_FAILED' },
        })
      }
      if (result === 'invalid-credentials') {
        throw new GraphQLError('Audible credentials are invalid', {
          extensions: { code: 'UNAUTHORIZED' },
        })
      }
      return true
    },
  }),
)

builder.mutationField('audibleImportStart', (t) =>
  t.field({
    type: 'Boolean',
    description: "Démarrer l'import des livres Audible (tâche de fond)",
    resolve: async () => {
      const state = await importRunner.getState()
      if (state.phase === 'running' || state.phase === 'paused') {
        throw new GraphQLError('Import already in progress', {
          extensions: { code: 'CONFLICT' },
        })
      }

      importRunner.start(importTaskDefinition).catch((error) => {
        log.error('Background import failed', { error: String(error) })
      })

      return true
    },
  }),
)

builder.mutationField('audibleImportPause', (t) =>
  t.field({
    type: 'Boolean',
    description:
      "Mettre en pause ou reprendre l'import Audible. Retourne true si mis en pause, false si repris.",
    resolve: async () => {
      const state = await importRunner.getState()

      if (state.phase === 'paused') {
        importRunner.resume()
        return false
      }

      if (state.phase !== 'running') {
        throw new GraphQLError('No import in progress to pause', {
          extensions: { code: 'CONFLICT' },
        })
      }

      importRunner.pause()
      return true
    },
  }),
)

builder.mutationField('audibleImportCancel', (t) =>
  t.field({
    type: 'Boolean',
    description: "Annuler l'import Audible en cours",
    resolve: async () => {
      const state = await importRunner.getState()
      if (state.phase !== 'running' && state.phase !== 'paused') {
        throw new GraphQLError('No import in progress to cancel', {
          extensions: { code: 'CONFLICT' },
        })
      }

      importRunner.cancel()
      return true
    },
  }),
)
