import { AwardType, BookType, PublicRatingRef } from '~/domain/book/infrastructure/graphql/types'
import type { Book } from '~/domain/book/types'
import type { ScanResult } from '~/domain/scan/types'
import { builder } from '~/domain/shared/graphql/builder'

type BookPreviewData = { previewId: string } & ScanResult

export const BookPreviewType = builder.objectRef<BookPreviewData>('BookPreview').implement({
  description: 'Book preview after scan (before confirmation)',
  fields: (t) => ({
    previewId: t.exposeString('previewId', { description: 'Preview identifier' }),
    title: t.exposeString('title', { description: 'Extracted title' }),
    authors: t.stringList({ description: 'Extracted authors', resolve: ({ authors }) => authors }),
    publisher: t.string({
      nullable: true,
      description: 'Publisher',
      resolve: ({ publisher }) => publisher ?? null,
    }),
    publishedDate: t.string({
      nullable: true,
      description: 'Publication date',
      resolve: ({ publishedDate }) => publishedDate ?? null,
    }),
    pageCount: t.int({
      nullable: true,
      description: 'Page count',
      resolve: ({ pageCount }) => pageCount ?? null,
    }),
    genre: t.string({
      nullable: true,
      description: 'Genre',
      resolve: ({ genre }) => genre ?? null,
    }),
    synopsis: t.string({
      nullable: true,
      description: 'Synopsis',
      resolve: ({ synopsis }) => synopsis ?? null,
    }),
    isbn: t.string({ nullable: true, description: 'ISBN', resolve: ({ isbn }) => isbn ?? null }),
    language: t.string({
      nullable: true,
      description: 'Language',
      resolve: ({ language }) => language ?? null,
    }),
    format: t.string({
      nullable: true,
      description: 'Format',
      resolve: ({ format }) => format ?? null,
    }),
    series: t.string({
      nullable: true,
      description: 'Series',
      resolve: ({ series }) => series ?? null,
    }),
    seriesLabel: t.string({
      nullable: true,
      description: 'Series label',
      resolve: ({ seriesLabel }) => seriesLabel ?? null,
    }),
    seriesNumber: t.float({
      nullable: true,
      description: 'Series position',
      resolve: ({ seriesNumber }) => seriesNumber ?? null,
    }),
    translator: t.string({
      nullable: true,
      description: 'Translator',
      resolve: ({ translator }) => translator ?? null,
    }),
    estimatedPrice: t.float({
      nullable: true,
      description: 'Estimated price',
      resolve: ({ estimatedPrice }) => estimatedPrice ?? null,
    }),
    duration: t.string({
      nullable: true,
      description: 'Duration (audio)',
      resolve: ({ duration }) => duration ?? null,
    }),
    narrators: t.stringList({
      nullable: true,
      description: 'Narrators',
      resolve: ({ narrators }) => narrators ?? null,
    }),
    awards: t.field({
      type: [AwardType],
      description: 'Literary awards',
      resolve: ({ awards }) => awards,
    }),
    publicRatings: t.field({
      type: [PublicRatingRef],
      description: 'Community ratings',
      resolve: ({ publicRatings }) =>
        publicRatings.map(({ source, score, maxScore, voterCount, url }) => ({
          source,
          score,
          maxScore,
          voterCount,
          url: url ?? '',
        })) as never,
    }),
  }),
})

type ConfirmResult = {
  tag: 'created' | 'duplicate' | 'replaced'
  book: Book
}

export const ConfirmBookResultType = builder
  .objectRef<ConfirmResult>('ConfirmBookResult')
  .implement({
    description: 'Scan confirmation result',
    fields: (t) => ({
      tag: t.exposeString('tag', { description: 'Result: created, duplicate, or replaced' }),
      book: t.field({
        type: BookType,
        description: 'Created or found book',
        resolve: ({ book }) => book,
      }),
    }),
  })
