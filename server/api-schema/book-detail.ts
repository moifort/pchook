import { z } from 'zod'
import { bookSchema } from './book'

export const seriesBookEntrySchema = z.object({
  id: z.string(),
  title: z.string(),
  label: z.string(),
  position: z.number(),
})

export const seriesInfoSchema = z.object({
  name: z.string(),
  label: z.string(),
  position: z.number(),
  books: z.array(seriesBookEntrySchema),
})

export const reviewSchema = z.object({
  bookId: z.string(),
  rating: z.number().int(),
  readDate: z.string().datetime().optional(),
  reviewNotes: z.string().optional(),
  createdAt: z.string().datetime(),
})

export const bookDetailViewSchema = z.object({
  book: bookSchema,
  coverImageBase64: z.string().optional(),
  series: seriesInfoSchema.optional(),
  review: reviewSchema.optional(),
})
