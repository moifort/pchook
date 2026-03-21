import { z } from 'zod'
import {
  audibleStatusSchema,
  authCookieSchema,
  authStartResponseSchema,
  awardSchema,
  bookCountSchema,
  bookDetailViewSchema,
  bookListItemSchema,
  bookPreviewSchema,
  bookSchema,
  dashboardViewSchema,
  favoriteBookSchema,
  publicRatingSchema,
  recentAwardSchema,
  recentBookSchema,
  reviewSchema,
  seriesBookEntrySchema,
  seriesInfoSchema,
  syncProgressSchema,
} from './index'

const schemas = {
  Award: awardSchema,
  PublicRating: publicRatingSchema,
  Book: bookSchema,
  BookPreview: bookPreviewSchema,
  BookListItem: bookListItemSchema,
  SeriesBookEntry: seriesBookEntrySchema,
  SeriesInfo: seriesInfoSchema,
  Review: reviewSchema,
  BookDetailView: bookDetailViewSchema,
  BookCount: bookCountSchema,
  FavoriteBook: favoriteBookSchema,
  RecentBook: recentBookSchema,
  RecentAward: recentAwardSchema,
  DashboardView: dashboardViewSchema,
  AuthCookie: authCookieSchema,
  AuthStartResponse: authStartResponseSchema,
  AudibleStatus: audibleStatusSchema,
  SyncProgress: syncProgressSchema,
} as const

const jsonSchemas = Object.fromEntries(
  Object.entries(schemas).map(([name, schema]) => [name, z.toJSONSchema(schema)]),
)

const output = JSON.stringify(jsonSchemas, null, 2)
await Bun.write('shared/api-schemas.json', output)

process.stdout.write(
  `Exported ${Object.keys(jsonSchemas).length} schemas to shared/api-schemas.json\n`,
)
