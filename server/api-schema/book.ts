import { z } from 'zod'

export const awardSchema = z.object({
  name: z.string(),
  year: z.number().int().optional(),
})

export const publicRatingSchema = z.object({
  source: z.string(),
  score: z.number(),
  maxScore: z.number(),
  voterCount: z.number().int(),
  url: z.string().optional(),
})

export const bookSchema = z.object({
  id: z.string(),
  title: z.string(),
  authors: z.array(z.string()),
  publisher: z.string().optional(),
  publishedDate: z.string().datetime().optional(),
  pageCount: z.number().int().optional(),
  genre: z.string().optional(),
  synopsis: z.string().optional(),
  isbn: z.string().optional(),
  language: z.string().optional(),
  format: z.string().optional(),
  translator: z.string().optional(),
  estimatedPrice: z.number().optional(),
  duration: z.string().optional(),
  narrators: z.array(z.string()),
  personalNotes: z.string().optional(),
  status: z.string(),
  readDate: z.string().datetime().optional(),
  awards: z.array(awardSchema),
  publicRatings: z.array(publicRatingSchema),
  importSource: z.string().optional(),
  externalUrl: z.string().optional(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
})

export const bookPreviewSchema = z.object({
  previewId: z.string(),
  title: z.string(),
  authors: z.array(z.string()),
  publisher: z.string().optional(),
  publishedDate: z.string().optional(),
  pageCount: z.number().int().optional(),
  genre: z.string().optional(),
  synopsis: z.string().optional(),
  isbn: z.string().optional(),
  language: z.string().optional(),
  format: z.string().optional(),
  series: z.string().optional(),
  seriesLabel: z.string().optional(),
  seriesNumber: z.number().int().optional(),
  translator: z.string().optional(),
  estimatedPrice: z.number().optional(),
  duration: z.string().optional(),
  narrators: z.array(z.string()).optional(),
  awards: z.array(awardSchema),
  publicRatings: z.array(publicRatingSchema),
  coverImageBase64: z.string().optional(),
})
