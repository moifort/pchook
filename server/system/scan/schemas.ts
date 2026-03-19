import { z } from 'zod'
import type { ScanResult } from '~/system/scan/types'

const nullToUndefined = <T>(schema: z.ZodType<T>) =>
  schema.nullish().transform((v) => v ?? undefined)

const awardSchema = z.object({
  name: z.string().min(1),
  year: nullToUndefined(z.number().int().positive()),
})

const publicRatingSchema = z.object({
  source: z.string().min(1),
  score: z.number(),
  maxScore: z.number(),
  voterCount: z.number().int().nonnegative(),
})

export const scanResultSchema = z
  .object({
    title: z.string().min(1),
    authors: z.array(z.string().min(1)).min(1),
    publisher: nullToUndefined(z.string().min(1)),
    publishedDate: nullToUndefined(z.string()),
    pageCount: nullToUndefined(z.number().int().positive()),
    genre: nullToUndefined(z.string().min(1)),
    synopsis: nullToUndefined(z.string().min(1)),
    isbn: nullToUndefined(z.string().min(10).max(17)),
    language: nullToUndefined(z.string().min(1)),
    format: nullToUndefined(z.string()),
    series: nullToUndefined(z.string().min(1)),
    seriesNumber: nullToUndefined(z.number()),
    translator: nullToUndefined(z.string().min(1)),
    estimatedPrice: nullToUndefined(z.number().nonnegative()),
    duration: nullToUndefined(z.string()),
    narrators: z
      .array(z.string().min(1))
      .nullish()
      .transform((v) => v ?? undefined),
    awards: z
      .array(awardSchema)
      .nullish()
      .transform((v) => v ?? []),
    publicRatings: z
      .array(publicRatingSchema)
      .nullish()
      .transform((v) => v ?? []),
  })
  .transform((v) => v satisfies ScanResult)

export const partialScanResultSchema = z.object({
  title: nullToUndefined(z.string().min(1)),
  authors: z
    .array(z.string().min(1))
    .nullish()
    .transform((v) => v ?? undefined),
  publisher: nullToUndefined(z.string().min(1)),
  publishedDate: nullToUndefined(z.string()),
  pageCount: nullToUndefined(z.number().int().positive()),
  genre: nullToUndefined(z.string().min(1)),
  synopsis: nullToUndefined(z.string().min(1)),
  isbn: nullToUndefined(z.string().min(10).max(17)),
  language: nullToUndefined(z.string().min(1)),
  format: nullToUndefined(z.string()),
  series: nullToUndefined(z.string().min(1)),
  seriesNumber: nullToUndefined(z.number()),
  translator: nullToUndefined(z.string().min(1)),
  estimatedPrice: nullToUndefined(z.number().nonnegative()),
  duration: nullToUndefined(z.string()),
  narrators: z
    .array(z.string().min(1))
    .nullish()
    .transform((v) => v ?? undefined),
  awards: z
    .array(awardSchema)
    .nullish()
    .transform((v) => v ?? []),
  publicRatings: z
    .array(publicRatingSchema)
    .nullish()
    .transform((v) => v ?? []),
})
