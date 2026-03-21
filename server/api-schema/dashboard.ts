import { z } from 'zod'

export const bookCountSchema = z.object({
  total: z.number().int(),
  toRead: z.number().int(),
  read: z.number().int(),
})

export const favoriteBookSchema = z.object({
  id: z.string(),
  title: z.string(),
  authors: z.array(z.string()),
  genre: z.string().optional(),
  rating: z.number().int(),
  readDate: z.string().datetime().optional(),
  estimatedPrice: z.number().optional(),
})

export const recentBookSchema = z.object({
  id: z.string(),
  title: z.string(),
  authors: z.array(z.string()),
  genre: z.string().optional(),
  createdAt: z.string().datetime(),
})

export const recentAwardSchema = z.object({
  bookTitle: z.string(),
  authors: z.array(z.string()),
  awardName: z.string(),
  awardYear: z.number().int(),
})

export const dashboardViewSchema = z.object({
  bookCount: bookCountSchema,
  favorites: z.array(favoriteBookSchema),
  recentBooks: z.array(recentBookSchema),
  recentAwards: z.array(recentAwardSchema),
})
