import { z } from 'zod'

export const authCookieSchema = z.object({
  name: z.string(),
  value: z.string(),
  domain: z.string(),
})

export const authStartResponseSchema = z.object({
  loginUrl: z.string(),
  sessionId: z.string(),
  cookies: z.array(authCookieSchema),
})

export const importTaskStateSchema = z.object({
  phase: z.string(),
  current: z.number().int(),
  total: z.number().int(),
  message: z.string(),
  startedAt: z.string().datetime().nullable(),
  completedAt: z.string().datetime().nullable(),
})

export const audibleStatusSchema = z.object({
  connected: z.boolean(),
  fetchInProgress: z.boolean(),
  libraryCount: z.number().int(),
  wishlistCount: z.number().int(),
  lastSyncAt: z.string().datetime().optional(),
  lastFetchedAt: z.string().datetime().optional(),
  rawItemCount: z.number().int(),
  importTask: importTaskStateSchema,
})
