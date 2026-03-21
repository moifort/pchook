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

export const audibleStatusSchema = z.object({
  connected: z.boolean(),
  libraryCount: z.number().int(),
  wishlistCount: z.number().int(),
  lastSyncAt: z.string().datetime().optional(),
  rawItemCount: z.number().int(),
})

export const syncProgressSchema = z.object({
  phase: z.string(),
  current: z.number().int(),
  total: z.number().int(),
  message: z.string(),
})
