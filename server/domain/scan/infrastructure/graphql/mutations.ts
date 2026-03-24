import { GraphQLError } from 'graphql'
import { match } from 'ts-pattern'
import { BookId, ISBN } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { BookUseCase } from '~/domain/book/use-case'
import * as previewRepository from '~/domain/scan/infrastructure/preview-repository'
import { IsbnScanner } from '~/domain/scan/isbn-scanner'
import { BookScanner } from '~/domain/scan/scanner'
import { ShareImporter } from '~/domain/scan/share-import'
import { scanResultToBookData } from '~/domain/scan/to-book-data'
import type { ScanResult } from '~/domain/scan/types'
import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { Url } from '~/domain/shared/primitives'
import { createLogger } from '~/system/logger'
import { BookPreviewType, ConfirmBookResultType } from './types'

const log = createLogger('scan-graphql')

builder.mutationField('analyzeBookCover', (t) =>
  t.field({
    type: BookPreviewType,
    description: 'Scan a book cover to extract metadata',
    args: {
      imageBase64: t.arg.string({ required: true, description: 'Base64-encoded image' }),
      ocrText: t.arg.string({ description: 'Optional OCR text' }),
    },
    resolve: async (_, { imageBase64, ocrText }) => {
      log.info('Received analyze request', {
        imageSize: imageBase64.length,
        ocrText: ocrText ?? null,
      })

      const imageBuffer = Buffer.from(imageBase64, 'base64')
      const allSeries = await SeriesQuery.findAll()
      const seriesNames = allSeries.map(({ name }) => String(name))
      const scanOutput = await BookScanner.scan(imageBuffer, ocrText ?? undefined, seriesNames)
      const previewId = crypto.randomUUID()

      await previewRepository.save({
        previewId,
        scanResult: scanOutput.result,
        coverImageBase64: scanOutput.coverImageBase64 ?? imageBase64,
        importSource: 'scan',
        createdAt: new Date(),
      })

      return { previewId, ...scanOutput.result }
    },
  }),
)

builder.mutationField('analyzeISBN', (t) =>
  t.field({
    type: BookPreviewType,
    nullable: true,
    description: 'Scan an ISBN barcode. Returns null if the book already exists.',
    args: {
      isbn: t.arg({ type: 'ISBN', required: true, description: 'ISBN code (10 or 13 digits)' }),
    },
    resolve: async (_, { isbn: rawIsbn }) => {
      const isbn = ISBN(rawIsbn)

      const existing = await BookQuery.findByISBN(isbn)
      if (existing) return null

      const allSeries = await SeriesQuery.findAll()
      const seriesNames = allSeries.map(({ name }) => String(name))
      const scanOutput = await IsbnScanner.scan(isbn, seriesNames)
      const previewId = crypto.randomUUID()

      await previewRepository.save({
        previewId,
        scanResult: scanOutput.result,
        coverImageBase64: scanOutput.coverImageBase64,
        importSource: 'isbn',
        createdAt: new Date(),
      })

      return { previewId, ...scanOutput.result }
    },
  }),
)

builder.mutationField('analyzeURL', (t) =>
  t.field({
    type: BookPreviewType,
    description: 'Import a book from a URL (Goodreads, Storygraph, etc.)',
    args: {
      url: t.arg({ type: 'Url', required: true, description: 'Book URL' }),
      description: t.arg.string({ description: 'Shared description' }),
      rawText: t.arg.string({ description: 'Shared raw text' }),
    },
    resolve: async (_, { url, description, rawText }) => {
      const allSeries = await SeriesQuery.findAll()
      const seriesNames = allSeries.map(({ name }) => String(name))
      const result = await ShareImporter.importFromShare(
        { url, description: description ?? undefined, rawText: rawText ?? undefined },
        seriesNames,
      )

      if (result === 'extraction-failed') {
        throw new GraphQLError('Could not identify the book from this URL', {
          extensions: { code: 'EXTRACTION_FAILED' },
        })
      }

      const previewId = crypto.randomUUID()

      await previewRepository.save({
        previewId,
        scanResult: result,
        importSource: 'url',
        externalUrl: Url(url),
        createdAt: new Date(),
      })

      return { previewId, ...result }
    },
  }),
)

const ConfirmBookInput = builder.inputType('ConfirmBookInput', {
  description: 'Data to confirm and create a book from a scan',
  fields: (t) => ({
    previewId: t.string({ required: true, description: 'Preview identifier' }),
    status: t.string({ required: true, description: 'Initial status (to-read or read)' }),
    replaceBookId: t.field({ type: 'BookId', description: 'ID of the book to replace (update)' }),
    title: t.field({ type: 'BookTitle', description: 'Title (override)' }),
    authors: t.field({ type: ['PersonName'], description: 'Authors (override)' }),
    publisher: t.field({ type: 'Publisher', description: 'Publisher (override)' }),
    pageCount: t.field({ type: 'PageCount', description: 'Pages (override)' }),
    genre: t.field({ type: 'Genre', description: 'Genre (override)' }),
    synopsis: t.string({ description: 'Synopsis (override)' }),
    language: t.field({ type: 'Language', description: 'Language (override)' }),
    format: t.string({ description: 'Format (override)' }),
    translator: t.field({ type: 'PersonName', description: 'Translator (override)' }),
    estimatedPrice: t.field({ type: 'Eur', description: 'Price (override)' }),
    series: t.field({ type: 'SeriesName', description: 'Series (override)' }),
    seriesLabel: t.field({ type: 'SeriesLabel', description: 'Series label (override)' }),
    seriesNumber: t.field({ type: 'SeriesPosition', description: 'Series position (override)' }),
  }),
})

builder.mutationField('confirmBook', (t) =>
  t.field({
    type: ConfirmBookResultType,
    description: 'Confirm and create a book from a scan preview',
    args: {
      input: t.arg({ type: ConfirmBookInput, required: true }),
    },
    resolve: async (_, { input }) => {
      const preview = await previewRepository.findBy(input.previewId)
      if (!preview) {
        throw new GraphQLError('Preview not found or expired', {
          extensions: { code: 'NOT_FOUND' },
        })
      }

      const overrides = Object.fromEntries(
        Object.entries(input).filter(
          ([key, v]) =>
            v !== undefined && key !== 'previewId' && key !== 'status' && key !== 'replaceBookId',
        ),
      )
      const mergedScanResult =
        Object.keys(overrides).length > 0
          ? { ...preview.scanResult, ...overrides }
          : preview.scanResult
      const { title, data, seriesInfo } = scanResultToBookData(mergedScanResult as ScanResult)

      const coverImageBuffer = preview.coverImageBase64
        ? Buffer.from(preview.coverImageBase64, 'base64')
        : undefined

      if (input.replaceBookId) {
        const result = await BookUseCase.replaceFromScan(
          BookId(input.replaceBookId),
          title,
          {
            ...data,
            status: input.status as 'to-read' | 'read',
            importSource: preview.importSource,
            externalUrl: preview.externalUrl,
          },
          seriesInfo,
          coverImageBuffer,
        )

        await previewRepository.remove(input.previewId)

        return match(result)
          .with({ tag: 'replaced' }, ({ book }) => ({ tag: 'replaced' as const, book }))
          .with({ tag: 'not-found' }, () => {
            throw new GraphQLError('Book to replace not found', {
              extensions: { code: 'NOT_FOUND' },
            })
          })
          .exhaustive()
      }

      const result = await BookUseCase.addFromScan(
        title,
        {
          ...data,
          status: input.status as 'to-read' | 'read',
          importSource: preview.importSource,
          externalUrl: preview.externalUrl,
        },
        seriesInfo,
        coverImageBuffer,
      )

      previewRepository.remove(input.previewId)

      return match(result)
        .with({ tag: 'created' }, ({ book }) => ({ tag: 'created' as const, book }))
        .with({ tag: 'duplicate' }, ({ book }) => ({ tag: 'duplicate' as const, book }))
        .exhaustive()
    },
  }),
)
