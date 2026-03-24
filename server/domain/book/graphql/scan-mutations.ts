import { GraphQLError } from 'graphql'
import { match } from 'ts-pattern'
import { BookId, ISBN } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { BookUseCase } from '~/domain/book/use-case'
import { SeriesQuery } from '~/domain/series/query'
import { builder } from '~/domain/shared/graphql/builder'
import { Url } from '~/domain/shared/primitives'
import { createLogger } from '~/system/logger'
import { BookScanner } from '~/system/scan/index'
import { IsbnScanner } from '~/system/scan/isbn-scanner'
import * as previewRepository from '~/system/scan/preview-repository'
import { ShareImporter } from '~/system/scan/share-import'
import { scanResultToBookData } from '~/system/scan/to-book-data'
import type { ScanResult } from '~/system/scan/types'
import { BookPreviewType, ConfirmBookResultType } from './scan-types'

const log = createLogger('scan-graphql')

builder.mutationField('analyzeBookCover', (t) =>
  t.field({
    type: BookPreviewType,
    description: 'Scanner une couverture de livre pour extraire les métadonnées',
    args: {
      imageBase64: t.arg.string({ required: true, description: 'Image en base64' }),
      ocrText: t.arg.string({ description: 'Texte OCR optionnel' }),
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
    description: 'Scanner un code-barres ISBN. Retourne null si le livre existe déjà.',
    args: {
      isbn: t.arg.string({ required: true, description: 'Code ISBN (10 ou 13 chiffres)' }),
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
    description: 'Importer un livre depuis une URL (Goodreads, Storygraph, etc.)',
    args: {
      url: t.arg.string({ required: true, description: 'URL du livre' }),
      description: t.arg.string({ description: 'Description partagée' }),
      rawText: t.arg.string({ description: 'Texte brut partagé' }),
    },
    resolve: async (_, { url, description, rawText }) => {
      const allSeries = await SeriesQuery.findAll()
      const seriesNames = allSeries.map(({ name }) => String(name))
      const result = await ShareImporter.importFromShare(
        { url, description: description ?? undefined, rawText: rawText ?? undefined },
        seriesNames,
      )

      if (result === 'extraction-failed') {
        throw new GraphQLError("Impossible d'identifier le livre à partir de cette URL", {
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
  description: 'Données pour confirmer et créer un livre depuis un scan',
  fields: (t) => ({
    previewId: t.string({ required: true, description: 'Identifiant du preview' }),
    status: t.string({ required: true, description: 'Statut initial (to-read ou read)' }),
    replaceBookId: t.string({ description: 'ID du livre à remplacer (mise à jour)' }),
    title: t.string({ description: 'Titre (override)' }),
    authors: t.stringList({ description: 'Auteurs (override)' }),
    publisher: t.string({ description: 'Éditeur (override)' }),
    pageCount: t.int({ description: 'Pages (override)' }),
    genre: t.string({ description: 'Genre (override)' }),
    synopsis: t.string({ description: 'Synopsis (override)' }),
    language: t.string({ description: 'Langue (override)' }),
    format: t.string({ description: 'Format (override)' }),
    translator: t.string({ description: 'Traducteur (override)' }),
    estimatedPrice: t.float({ description: 'Prix (override)' }),
    series: t.string({ description: 'Série (override)' }),
    seriesLabel: t.string({ description: 'Label série (override)' }),
    seriesNumber: t.float({ description: 'Position série (override)' }),
  }),
})

builder.mutationField('confirmBook', (t) =>
  t.field({
    type: ConfirmBookResultType,
    description: 'Confirmer et créer un livre depuis un preview de scan',
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
          preview.coverImageBase64,
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
        preview.coverImageBase64,
      )

      previewRepository.remove(input.previewId)

      return match(result)
        .with({ tag: 'created' }, ({ book }) => ({ tag: 'created' as const, book }))
        .with({ tag: 'duplicate' }, ({ book }) => ({ tag: 'duplicate' as const, book }))
        .exhaustive()
    },
  }),
)
