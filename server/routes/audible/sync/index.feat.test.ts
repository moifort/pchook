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
    isFinished: true,
  },
  {
    asin: Asin('B07XYZTEST'),
    title: 'Neuromancien',
    authors: ['William Gibson'],
    narrators: ['Olivier Chauvel'],
    durationMinutes: 540,
    publisher: 'Audible Studios',
    language: 'fr',
    isFinished: false,
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
  verifyConnection: async () => {},
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
import { AudibleUseCase } from '~/domain/audible/use-case'
import { BookQuery } from '~/domain/book/query'
import fetchHandler from '~/routes/audible/sync/fetch.post'
import importHandler from '~/routes/audible/sync/import.post'
import verifyHandler from '~/routes/audible/sync/verify.post'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('POST /audible/sync/verify', () => {
  scenario('returns verified when credentials are valid', async () => {
    given('Audible credentials are configured')
    await AudibleCommand.saveCredentials(fakeCredentials)

    when('POST /audible/sync/verify is called')
    const event = mockEvent()
    const result = await verifyHandler(event as never)

    then('it returns verified status')
    expect(result.status).toBe(200)
    expect(result.data.verified).toBe(true)
  })

  scenario('rejects when no credentials are configured', async () => {
    given('no Audible credentials exist')

    when('POST /audible/sync/verify is called')
    const event = mockEvent()

    then('it throws a 422 error')
    await expect(verifyHandler(event as never)).rejects.toMatchObject({ statusCode: 422 })
  })
})

feature('POST /audible/sync/fetch', () => {
  scenario('accepts fetch request and starts background processing', async () => {
    given('Audible credentials are configured')
    await AudibleCommand.saveCredentials(fakeCredentials)

    when('POST /audible/sync/fetch is called')
    const result = await fetchHandler(mockEvent() as never)

    then('it returns 202 with started flag')
    expect(result.status).toBe(202)
    expect(result.data.started).toBe(true)
  })

  scenario('rejects when no credentials are configured', async () => {
    given('no Audible credentials exist')

    then('it throws a 422 error')
    await expect(fetchHandler(mockEvent() as never)).rejects.toMatchObject({ statusCode: 422 })
  })
})

feature('POST /audible/sync/import', () => {
  scenario('accepts import request and starts background processing', async () => {
    given('Audible credentials are configured and raw items were fetched')
    await AudibleCommand.saveCredentials(fakeCredentials)
    await AudibleUseCase.fetchAndStore()

    when('POST /audible/sync/import is called')
    const result = await importHandler(mockEvent() as never)

    then('it returns 202 with started flag')
    expect(result.status).toBe(202)
    expect(result.data.started).toBe(true)
  })

  scenario('rejects when no raw data was fetched', async () => {
    given('no Audible data has been fetched')

    then('it throws a 422 error')
    await expect(importHandler(mockEvent() as never)).rejects.toMatchObject({ statusCode: 422 })
  })
})

feature('Audible sync end-to-end', () => {
  scenario('imports stored raw items into books', async () => {
    given('Audible credentials are configured and raw items were fetched')
    await AudibleCommand.saveCredentials(fakeCredentials)
    await AudibleUseCase.fetchAndStore()

    when('import is executed')
    const result = await AudibleUseCase.importAll()

    then('it returns the number of new books and duplicates')
    expect(result).toMatchObject({ newBooksAdded: 3, duplicatesSkipped: 0 })

    and('books are created with audiobook format and correct status')
    const books = await BookQuery.findAll()
    expect(books).toHaveLength(3)

    const dune = books.find((b) => String(b.title) === 'Dune')
    expect(dune).toBeDefined()
    expect(dune?.format).toBe('audiobook')
    expect(dune?.status).toBe('read')
    expect(dune?.duration).toBe('21h 30min')
    expect(dune?.narrators?.map(String)).toEqual(['Benjamin Jungers'])

    const neuromancien = books.find((b) => String(b.title) === 'Neuromancien')
    expect(neuromancien).toBeDefined()
    expect(neuromancien?.format).toBe('audiobook')
    expect(neuromancien?.status).toBe('to-read')

    const fondation = books.find((b) => String(b.title) === 'Fondation')
    expect(fondation).toBeDefined()
    expect(fondation?.format).toBe('audiobook')
    expect(fondation?.status).toBe('to-read')
  })

  scenario('skips already-imported ASINs on re-import', async () => {
    given('Audible data was fetched and a first import was done')
    await AudibleCommand.saveCredentials(fakeCredentials)
    await AudibleUseCase.fetchAndStore()
    await AudibleUseCase.importAll()

    when('import is executed again')
    const result = await AudibleUseCase.importAll()

    then('all items are skipped as duplicates')
    expect(result).toMatchObject({ newBooksAdded: 0, duplicatesSkipped: 3 })

    and('no duplicate books are created')
    const books = await BookQuery.findAll()
    expect(books).toHaveLength(3)
  })
})
