import { describe, expect, test } from 'bun:test'
import type { Book, PublicRating } from '~/domain/book/types'
import type { Review } from '~/domain/review/types'
import type { BookDetailView, SeriesInfo } from '~/read-model/book-detail/types'
import type { BookListItem } from '~/read-model/book-list/types'
import type { DashboardView } from '~/read-model/dashboard/types'
import type { ScanResult } from '~/system/scan/types'
import {
  audibleStatusSchema,
  authStartResponseSchema,
  bookDetailViewSchema,
  bookListItemSchema,
  bookPreviewSchema,
  bookSchema,
  dashboardViewSchema,
  importTaskStateSchema,
} from './index'

// Helpers to build typed sample data and validate it through JSON round-trip
const throughJson = <T>(value: T): unknown => JSON.parse(JSON.stringify(value))

const sampleBook: Book = {
  id: '550e8400-e29b-41d4-a716-446655440000' as Book['id'],
  title: 'Test Book' as Book['title'],
  authors: ['Author One' as Book['authors'][0]],
  publisher: 'Publisher' as Book['publisher'],
  publishedDate: new Date('2024-01-15'),
  pageCount: 300 as Book['pageCount'],
  genre: 'Fiction' as Book['genre'],
  synopsis: 'A test book',
  isbn: '9781234567890' as Book['isbn'],
  language: 'FR' as Book['language'],
  format: 'paperback',
  translator: undefined,
  estimatedPrice: 19.99 as Book['estimatedPrice'],
  duration: undefined,
  narrators: [],
  personalNotes: undefined,
  status: 'to-read',
  readDate: undefined,
  awards: [{ name: 'Prix Goncourt', year: 2024 }],
  publicRatings: [
    {
      source: 'Babelio',
      score: 4.2 as PublicRating['score'],
      maxScore: 5 as PublicRating['maxScore'],
      voterCount: 1200,
      url: 'https://babelio.com/test' as PublicRating['url'],
    },
  ],
  importSource: 'scan',
  externalUrl: undefined,
  createdAt: new Date('2024-01-15T10:00:00Z'),
  updatedAt: new Date('2024-01-15T10:00:00Z'),
}

describe('API schema conformance', () => {
  test('Book schema validates a serialized Book', () => {
    const wire = throughJson(sampleBook)
    expect(() => bookSchema.parse(wire)).not.toThrow()
  })

  test('BookListItem schema validates a serialized BookListItem', () => {
    const item: BookListItem = {
      id: sampleBook.id,
      title: 'Test Book',
      authors: sampleBook.authors,
      genre: 'Fiction' as BookListItem['genre'],
      status: 'to-read',
      estimatedPrice: 19.99 as BookListItem['estimatedPrice'],
      language: undefined,
      awards: [{ name: 'Prix Goncourt', year: 2024 }],
      rating: 8 as BookListItem['rating'],
      seriesName: undefined,
      seriesLabel: undefined,
      seriesPosition: undefined,
      createdAt: new Date('2024-01-15T10:00:00Z'),
    }
    expect(() => bookListItemSchema.parse(throughJson(item))).not.toThrow()
  })

  test('BookDetailView schema validates a serialized BookDetailView', () => {
    const series: SeriesInfo = {
      name: 'Test Series',
      label: 'Tome 1',
      position: 1,
      books: [
        {
          id: sampleBook.id,
          title: 'Test Book',
          label: 'Tome 1',
          position: 1,
        },
      ],
    }
    const review: Review = {
      bookId: sampleBook.id,
      rating: 8 as Review['rating'],
      readDate: new Date('2024-02-01T00:00:00Z'),
      reviewNotes: 'Great book',
      createdAt: new Date('2024-02-01T10:00:00Z'),
    }
    const detail: BookDetailView = {
      book: sampleBook,
      coverImageBase64: 'base64data',
      series,
      review,
    }
    expect(() => bookDetailViewSchema.parse(throughJson(detail))).not.toThrow()
  })

  test('DashboardView schema validates a serialized DashboardView', () => {
    const dashboard: DashboardView = {
      bookCount: { total: 42, toRead: 10, read: 32 },
      favorites: [
        {
          id: sampleBook.id,
          title: 'Favorite',
          authors: sampleBook.authors,
          genre: 'Fiction' as DashboardView['favorites'][0]['genre'],
          rating: 9 as DashboardView['favorites'][0]['rating'],
          readDate: new Date('2024-01-01T00:00:00Z'),
          estimatedPrice: 15 as DashboardView['favorites'][0]['estimatedPrice'],
        },
      ],
      recentBooks: [
        {
          id: sampleBook.id,
          title: 'Recent',
          authors: sampleBook.authors,
          genre: undefined,
          createdAt: new Date('2024-01-15T10:00:00Z'),
        },
      ],
      recentAwards: [
        {
          bookTitle: 'Awarded Book',
          authors: sampleBook.authors,
          awardName: 'Prix Renaudot',
          awardYear: 2024,
        },
      ],
    }
    expect(() => dashboardViewSchema.parse(throughJson(dashboard))).not.toThrow()
  })

  test('BookPreview schema validates a serialized scan result with previewId', () => {
    const scanResult: ScanResult = {
      title: 'Scanned Book',
      authors: ['Author'],
      publisher: 'Pub',
      pageCount: 200,
      genre: 'Fiction',
      isbn: '9781234567890',
      language: 'FR',
      format: 'paperback',
      awards: [],
      publicRatings: [],
    }
    const preview = { previewId: '550e8400-e29b-41d4-a716-446655440001', ...scanResult }
    expect(() => bookPreviewSchema.parse(throughJson(preview))).not.toThrow()
  })

  test('AuthStartResponse schema validates auth start data', () => {
    const response = {
      loginUrl: 'https://amazon.fr/login',
      sessionId: 'session-123',
      cookies: [{ name: 'session-id', value: 'abc', domain: '.amazon.fr' }],
    }
    expect(() => authStartResponseSchema.parse(response)).not.toThrow()
  })

  test('AudibleStatus schema validates status data', () => {
    const status = {
      connected: true,
      fetchInProgress: false,
      libraryCount: 42,
      wishlistCount: 5,
      lastSyncAt: new Date('2024-01-15T10:00:00Z').toISOString(),
      lastFetchedAt: new Date('2024-01-15T10:00:00Z').toISOString(),
      rawItemCount: 47,
      importTask: {
        phase: 'idle',
        current: 0,
        total: 0,
        message: '',
        startedAt: null,
        completedAt: null,
      },
    }
    expect(() => audibleStatusSchema.parse(status)).not.toThrow()
  })

  test('ImportTaskState schema validates task state data', () => {
    const taskState = {
      phase: 'importing',
      current: 5,
      total: 42,
      message: 'Importing 5/42...',
      startedAt: new Date('2024-01-15T10:00:00Z').toISOString(),
      completedAt: null,
    }
    expect(() => importTaskStateSchema.parse(taskState)).not.toThrow()
  })
})
