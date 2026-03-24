import { GraphQLError } from 'graphql'
import { z } from 'zod'
import { AudibleCommand } from '~/domain/audible/command'
import { generateLoginUrl, registerDevice } from '~/domain/audible/infrastructure/audible.api'
import { AudibleLocale } from '~/domain/audible/primitives'
import { AudibleQuery } from '~/domain/audible/query'
import {
  AUDIBLE_IMPORT_TASK_ID,
  AudibleUseCase,
  importTaskDefinition,
} from '~/domain/audible/use-case'
import { builder } from '~/domain/shared/graphql/builder'
import { TaskType } from '~/domain/task/graphql/types'
import { TaskQuery } from '~/domain/task/query'
import { TaskRunner } from '~/domain/task/runner'
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
      await TaskRunner.reset(AUDIBLE_IMPORT_TASK_ID)
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
    type: TaskType,
    description: "Démarrer l'import des livres Audible (tâche de fond)",
    resolve: async () => {
      const state = await TaskQuery.getById(AUDIBLE_IMPORT_TASK_ID)
      if (state !== 'not-found' && (state.phase === 'running' || state.phase === 'paused')) {
        throw new GraphQLError('Import already in progress', {
          extensions: { code: 'CONFLICT' },
        })
      }

      TaskRunner.start(AUDIBLE_IMPORT_TASK_ID, importTaskDefinition).catch((error) => {
        log.error('Background import failed', { error: String(error) })
      })

      // Wait a tick for the task state to be initialized
      await new Promise((resolve) => setTimeout(resolve, 10))
      const taskState = await TaskQuery.getById(AUDIBLE_IMPORT_TASK_ID)
      if (taskState === 'not-found') throw new Error('Task state not initialized')
      return taskState
    },
  }),
)
