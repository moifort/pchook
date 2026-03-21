import { z } from 'zod'
import { awardSchema } from './book'

export const bookListItemSchema = z.object({
  id: z.string(),
  title: z.string(),
  authors: z.array(z.string()),
  genre: z.string().optional(),
  status: z.string(),
  estimatedPrice: z.number().optional(),
  language: z.string().optional(),
  awards: z.array(awardSchema),
  rating: z.number().int().optional(),
  seriesName: z.string().optional(),
  seriesLabel: z.string().optional(),
  seriesPosition: z.number().optional(),
  createdAt: z.string().datetime(),
})
