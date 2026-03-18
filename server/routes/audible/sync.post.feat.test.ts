import { expect, mock } from 'bun:test'
import { Asin } from '~/domain/audible/primitives'
import type { AudibleCredentials, AudibleItem } from '~/domain/audible/types'

const fakeCredentials: AudibleCredentials = {
  accessToken: 'fake-access-token',
  refreshToken: 'fake-refresh-token',
  adpToken: 'fake-adp-token',
  devicePrivateKey: 'fake-private-key',
  serial: 'FAKESERIALNUMBER1234567890ABCDEF',
  locale: 'fr',
  expiresAt: new Date(Date.now() + 3600 * 1000),
}

const fakeLibraryItems: AudibleItem[] = [
  {
    asin: Asin('B08G9PRS1K'),
    title: 'Dune',
    authors: ['Frank Herbert'],
    narrators: ['Benjamin Jungers'],
    durationMinutes: 1290,
    publisher: 'Audible Studios',
    language: 'fr',
    releaseDate: new Date('2020-01-15'),
    coverUrl: 'https://example.com/dune.jpg',
    series: { name: 'Dune', position: 1 },
  },
]

const fakeWishlistItems: AudibleItem[] = [
  {
    asin: Asin('B09ABCDEFG'),
    title: 'Fondation',
    authors: ['Isaac Asimov'],
    narrators: ['Laurent Natrella'],
    durationMinutes: 480,
    publisher: 'Audible Studios',
    language: 'fr',
  },
]

mock.module('~/domain/audible/audible.api', () => ({
  fetchLibrary: async (credentials: AudibleCredentials) => ({
    items: fakeLibraryItems,
    credentials,
  }),
  fetchWishlist: async (credentials: AudibleCredentials) => ({
    items: fakeWishlistItems,
    credentials,
  }),
  refreshAccessToken: async (credentials: AudibleCredentials) => credentials,
  generateLoginUrl: async () => ({
    loginUrl: 'https://example.com',
    sessionId: 'fake',
    cookies: [],
  }),
  registerDevice: async () => fakeCredentials,
}))

mock.module('~/system/scan/gemini', () => ({
  callGemini: async () => ({
    title: 'Gemini Title',
    authors: ['Gemini Author'],
    publisher: 'Gemini Publisher',
    publishedDate: '2020-01-01',
    pageCount: 300,
    genre: 'Science-Fiction',
    synopsis: 'Un résumé du livre.',
    isbn: null,
    language: 'FR',
    format: 'paperback',
    series: null,
    seriesNumber: null,
    translator: null,
    estimatedPrice: 20,
    awards: [],
    publicRatings: [{ source: 'Goodreads', score: 4.2, maxScore: 5, voterCount: 10000 }],
  }),
  buildBookJsonSchema: () => '{}',
  normalizeBookFormat: (value: string) => value,
}))

mock.module('~/system/suggestion/index', () => ({
  SuggestionGenerator: {
    generate: async () => [],
  },
}))

import { AudibleCommand } from '~/domain/audible/command'
import { BookQuery } from '~/domain/book/query'
import statusHandler from '~/routes/audible/status.get'
import syncHandler from '~/routes/audible/sync.post'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('POST /audible/sync', () => {
  scenario('syncs library and wishlist into books', async () => {
    given('Audible credentials are configured')
    await AudibleCommand.saveCredentials(fakeCredentials)

    when('POST /audible/sync is called')
    const event = mockEvent()
    const result = await syncHandler(event as never)

    then('sync returns correct counts')
    expect(result.status).toBe(200)
    expect(result.data.libraryCount).toBe(1)
    expect(result.data.wishlistCount).toBe(1)
    expect(result.data.newBooksAdded).toBe(2)
    expect(result.data.duplicatesSkipped).toBe(0)

    and('books are created with correct format and status')
    const books = await BookQuery.findAll()
    expect(books).toHaveLength(2)

    const dune = books.find((b) => String(b.title) === 'Dune')
    expect(dune).toBeDefined()
    expect(dune?.format).toBe('audiobook')
    expect(dune?.status).toBe('read')
    expect(dune?.duration).toBe('21h 30min')
    expect(dune?.narrators?.map(String)).toEqual(['Benjamin Jungers'])

    const fondation = books.find((b) => String(b.title) === 'Fondation')
    expect(fondation).toBeDefined()
    expect(fondation?.format).toBe('audiobook')
    expect(fondation?.status).toBe('to-read')
  })

  scenario('skips already-synced ASINs on re-sync', async () => {
    given('Audible credentials are configured and a first sync was done')
    await AudibleCommand.saveCredentials(fakeCredentials)
    const firstEvent = mockEvent()
    await syncHandler(firstEvent as never)

    when('POST /audible/sync is called again')
    const secondEvent = mockEvent()
    const result = await syncHandler(secondEvent as never)

    then('all items are skipped as duplicates')
    expect(result.data.newBooksAdded).toBe(0)
    expect(result.data.duplicatesSkipped).toBe(2)

    and('no duplicate books are created')
    const books = await BookQuery.findAll()
    expect(books).toHaveLength(2)
  })

  scenario('returns 422 when credentials are missing', async () => {
    given('no Audible credentials are configured')

    when('POST /audible/sync is called')
    const event = mockEvent()

    then('it throws a 422 error')
    try {
      await syncHandler(event as never)
      expect(true).toBe(false)
    } catch (error: unknown) {
      expect((error as { statusCode: number }).statusCode).toBe(422)
    }
  })
})

feature('GET /audible/status', () => {
  scenario('returns status after sync', async () => {
    given('credentials are configured and sync was performed')
    await AudibleCommand.saveCredentials(fakeCredentials)
    const syncEvent = mockEvent()
    await syncHandler(syncEvent as never)

    when('GET /audible/status is called')
    const event = mockEvent()
    const result = await statusHandler(event as never)

    then('status shows connected with correct counts')
    expect(result.status).toBe(200)
    expect(result.data.connected).toBe(true)
    expect(result.data.libraryCount).toBe(1)
    expect(result.data.wishlistCount).toBe(1)
    expect(result.data.lastSyncAt).toBeDefined()
  })

  scenario('returns disconnected when no credentials', async () => {
    given('no credentials are configured')

    when('GET /audible/status is called')
    const event = mockEvent()
    const result = await statusHandler(event as never)

    then('status shows not connected')
    expect(result.status).toBe(200)
    expect(result.data.connected).toBe(false)
    expect(result.data.libraryCount).toBe(0)
    expect(result.data.wishlistCount).toBe(0)
  })
})
