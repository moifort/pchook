import { AwardType, BookType, PublicRatingRef } from '~/domain/book/graphql/types'
import type { Book } from '~/domain/book/types'
import type { ScanResult } from '~/domain/scan/types'
import { builder } from '~/domain/shared/graphql/builder'

type BookPreviewData = { previewId: string } & ScanResult

export const BookPreviewType = builder.objectRef<BookPreviewData>('BookPreview').implement({
  description: "Preview d'un livre après scan (avant confirmation)",
  fields: (t) => ({
    previewId: t.exposeString('previewId', { description: 'Identifiant du preview' }),
    title: t.exposeString('title', { description: 'Titre extrait' }),
    authors: t.stringList({ description: 'Auteurs extraits', resolve: ({ authors }) => authors }),
    publisher: t.string({
      nullable: true,
      description: 'Éditeur',
      resolve: ({ publisher }) => publisher ?? null,
    }),
    publishedDate: t.string({
      nullable: true,
      description: 'Date de publication',
      resolve: ({ publishedDate }) => publishedDate ?? null,
    }),
    pageCount: t.int({
      nullable: true,
      description: 'Nombre de pages',
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
      description: 'Langue',
      resolve: ({ language }) => language ?? null,
    }),
    format: t.string({
      nullable: true,
      description: 'Format',
      resolve: ({ format }) => format ?? null,
    }),
    series: t.string({
      nullable: true,
      description: 'Série',
      resolve: ({ series }) => series ?? null,
    }),
    seriesLabel: t.string({
      nullable: true,
      description: 'Label série',
      resolve: ({ seriesLabel }) => seriesLabel ?? null,
    }),
    seriesNumber: t.float({
      nullable: true,
      description: 'Position série',
      resolve: ({ seriesNumber }) => seriesNumber ?? null,
    }),
    translator: t.string({
      nullable: true,
      description: 'Traducteur',
      resolve: ({ translator }) => translator ?? null,
    }),
    estimatedPrice: t.float({
      nullable: true,
      description: 'Prix estimé',
      resolve: ({ estimatedPrice }) => estimatedPrice ?? null,
    }),
    duration: t.string({
      nullable: true,
      description: 'Durée (audio)',
      resolve: ({ duration }) => duration ?? null,
    }),
    narrators: t.stringList({
      nullable: true,
      description: 'Narrateurs',
      resolve: ({ narrators }) => narrators ?? null,
    }),
    awards: t.field({
      type: [AwardType],
      description: 'Prix littéraires',
      resolve: ({ awards }) => awards,
    }),
    publicRatings: t.field({
      type: [PublicRatingRef],
      description: 'Notes communautaires',
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
    description: 'Résultat de la confirmation de scan',
    fields: (t) => ({
      tag: t.exposeString('tag', { description: 'Résultat: created, duplicate, ou replaced' }),
      book: t.field({
        type: BookType,
        description: 'Livre créé ou trouvé',
        resolve: ({ book }) => book,
      }),
    }),
  })
