import type { BookListItem as BookListItemModel } from '~/domain/book/read-model/types'
import type { Book, PublicRating as PublicRatingType } from '~/domain/book/types'
import { builder } from '~/domain/shared/graphql/builder'
import { BookFormatEnum, BookStatusEnum, ImportSourceEnum } from './enums'

export const AwardType = builder.objectRef<{ name: string; year?: number }>('Award').implement({
  description: 'Prix littéraire reçu par un livre',
  fields: (t) => ({
    name: t.exposeString('name', { description: 'Nom du prix' }),
    year: t.exposeInt('year', { nullable: true, description: "Année d'obtention" }),
  }),
})

export const PublicRatingRef = builder.objectRef<PublicRatingType>('PublicRating').implement({
  description: "Note communautaire provenant d'une plateforme externe",
  fields: (t) => ({
    source: t.exposeString('source', {
      description: 'Nom de la plateforme (ex: Hardcover, Goodreads)',
    }),
    score: t.float({ description: 'Note obtenue', resolve: ({ score }) => Number(score) }),
    maxScore: t.float({
      description: 'Note maximale possible',
      resolve: ({ maxScore }) => Number(maxScore),
    }),
    voterCount: t.exposeInt('voterCount', { description: 'Nombre de votants' }),
    url: t.string({
      description: 'Lien vers la page du livre sur la plateforme',
      resolve: ({ url }) => String(url),
    }),
  }),
})

export const BookType = builder.objectRef<Book>('Book').implement({
  description: 'Un livre dans la bibliothèque personnelle',
  fields: (t) => ({
    id: t.id({ description: 'Identifiant unique', resolve: ({ id }) => String(id) }),
    title: t.string({ description: 'Titre du livre', resolve: ({ title }) => String(title) }),
    authors: t.stringList({
      description: 'Auteurs du livre',
      resolve: ({ authors }) => authors.map(String),
    }),
    publisher: t.string({
      nullable: true,
      description: 'Éditeur',
      resolve: ({ publisher }) => (publisher ? String(publisher) : null),
    }),
    publishedDate: t.string({
      nullable: true,
      description: 'Date de publication (ISO 8601)',
      resolve: ({ publishedDate }) => publishedDate?.toISOString() ?? null,
    }),
    pageCount: t.int({
      nullable: true,
      description: 'Nombre de pages',
      resolve: ({ pageCount }) => (pageCount ? Number(pageCount) : null),
    }),
    genre: t.string({
      nullable: true,
      description: 'Genre littéraire (ex: Romance, SF, Polar)',
      resolve: ({ genre }) => (genre ? String(genre) : null),
    }),
    synopsis: t.exposeString('synopsis', { nullable: true, description: 'Résumé du livre' }),
    isbn: t.string({
      nullable: true,
      description: 'Numéro ISBN',
      resolve: ({ isbn }) => (isbn ? String(isbn) : null),
    }),
    language: t.string({
      nullable: true,
      description: 'Langue du livre (ex: fr, en)',
      resolve: ({ language }) => (language ? String(language) : null),
    }),
    format: t.field({
      type: BookFormatEnum,
      nullable: true,
      description: 'Format du livre',
      resolve: ({ format }) => format ?? null,
    }),
    translator: t.string({
      nullable: true,
      description: 'Traducteur',
      resolve: ({ translator }) => (translator ? String(translator) : null),
    }),
    estimatedPrice: t.float({
      nullable: true,
      description: 'Prix estimé en euros',
      resolve: ({ estimatedPrice }) => (estimatedPrice ? Number(estimatedPrice) : null),
    }),
    duration: t.exposeString('duration', { nullable: true, description: 'Durée (livre audio)' }),
    narrators: t.stringList({
      description: 'Narrateurs (livre audio)',
      resolve: ({ narrators }) => narrators.map(String),
    }),
    personalNotes: t.exposeString('personalNotes', {
      nullable: true,
      description: 'Notes personnelles',
    }),
    status: t.field({
      type: BookStatusEnum,
      description: 'Statut de lecture',
      resolve: ({ status }) => status,
    }),
    readDate: t.string({
      nullable: true,
      description: 'Date de lecture (ISO 8601)',
      resolve: ({ readDate }) => readDate?.toISOString() ?? null,
    }),
    awards: t.field({
      type: [AwardType],
      description: 'Prix littéraires',
      resolve: ({ awards }) => awards,
    }),
    publicRatings: t.field({
      type: [PublicRatingRef],
      description: 'Notes communautaires',
      resolve: ({ publicRatings }) => publicRatings,
    }),
    importSource: t.field({
      type: ImportSourceEnum,
      nullable: true,
      description: "Source d'import",
      resolve: ({ importSource }) => importSource ?? null,
    }),
    externalUrl: t.string({
      nullable: true,
      description: 'URL externe (Audible, etc.)',
      resolve: ({ externalUrl }) => (externalUrl ? String(externalUrl) : null),
    }),
    createdAt: t.string({
      description: "Date d'ajout à la bibliothèque (ISO 8601)",
      resolve: ({ createdAt }) => createdAt.toISOString(),
    }),
    updatedAt: t.string({
      description: 'Date de dernière modification (ISO 8601)',
      resolve: ({ updatedAt }) => updatedAt.toISOString(),
    }),
  }),
})

export const BookListItemType = builder.objectRef<BookListItemModel>('BookListItem').implement({
  description: 'Élément de la liste de livres (vue résumée)',
  fields: (t) => ({
    id: t.id({ description: 'Identifiant unique', resolve: ({ id }) => String(id) }),
    title: t.exposeString('title', { description: 'Titre du livre' }),
    authors: t.stringList({
      description: 'Auteurs',
      resolve: ({ authors }) => authors.map(String),
    }),
    genre: t.string({
      nullable: true,
      description: 'Genre littéraire',
      resolve: ({ genre }) => (genre ? String(genre) : null),
    }),
    status: t.field({
      type: BookStatusEnum,
      description: 'Statut de lecture',
      resolve: ({ status }) => status,
    }),
    estimatedPrice: t.float({
      nullable: true,
      description: 'Prix estimé en euros',
      resolve: ({ estimatedPrice }) => (estimatedPrice ? Number(estimatedPrice) : null),
    }),
    awards: t.field({
      type: [AwardType],
      description: 'Prix littéraires',
      resolve: ({ awards }) => awards,
    }),
    rating: t.int({
      nullable: true,
      description: 'Note personnelle (0-10)',
      resolve: ({ rating }) => (rating ? Number(rating) : null),
    }),
    language: t.exposeString('language', { nullable: true, description: 'Langue' }),
    seriesName: t.exposeString('seriesName', { nullable: true, description: 'Nom de la série' }),
    seriesLabel: t.exposeString('seriesLabel', {
      nullable: true,
      description: 'Label dans la série (ex: Tome 3)',
    }),
    seriesPosition: t.exposeInt('seriesPosition', {
      nullable: true,
      description: 'Position dans la série',
    }),
    createdAt: t.string({
      description: "Date d'ajout (ISO 8601)",
      resolve: ({ createdAt }) => createdAt.toISOString(),
    }),
  }),
})
