import { builder } from '~/domain/shared/graphql/builder'
import { BookFormatEnum, BookStatusEnum } from './enums'

const AwardInput = builder.inputType('AwardInput', {
  description: 'Prix littéraire',
  fields: (t) => ({
    name: t.string({ required: true, description: 'Nom du prix' }),
    year: t.int({ description: "Année d'obtention" }),
  }),
})

const PublicRatingInput = builder.inputType('PublicRatingInput', {
  description: 'Note communautaire externe',
  fields: (t) => ({
    source: t.string({ required: true, description: 'Nom de la plateforme' }),
    score: t.float({ required: true, description: 'Note obtenue' }),
    maxScore: t.float({ required: true, description: 'Note maximale possible' }),
    voterCount: t.int({ required: true, description: 'Nombre de votants' }),
    url: t.string({ required: true, description: 'URL de la page du livre' }),
  }),
})

export const UpdateBookInput = builder.inputType('UpdateBookInput', {
  description: "Champs modifiables d'un livre (tous optionnels)",
  fields: (t) => ({
    title: t.string({ description: 'Titre du livre' }),
    authors: t.stringList({ description: 'Auteurs' }),
    publisher: t.string({ description: 'Éditeur (null pour supprimer)' }),
    publishedDate: t.string({ description: 'Date de publication (ISO 8601)' }),
    pageCount: t.int({ description: 'Nombre de pages (null pour supprimer)' }),
    genre: t.string({ description: 'Genre littéraire (null pour supprimer)' }),
    synopsis: t.string({ description: 'Résumé' }),
    isbn: t.string({ description: 'Numéro ISBN (null pour supprimer)' }),
    language: t.string({ description: 'Langue (ex: fr, en)' }),
    format: t.field({ type: BookFormatEnum, description: 'Format du livre' }),
    translator: t.string({ description: 'Traducteur (null pour supprimer)' }),
    estimatedPrice: t.float({ description: 'Prix estimé en euros (null pour supprimer)' }),
    duration: t.string({ description: 'Durée (livre audio)' }),
    narrators: t.stringList({ description: 'Narrateurs (livre audio)' }),
    personalNotes: t.string({ description: 'Notes personnelles' }),
    status: t.field({ type: BookStatusEnum, description: 'Statut de lecture' }),
    readDate: t.string({ description: 'Date de lecture (ISO 8601)' }),
    awards: t.field({ type: [AwardInput], description: 'Prix littéraires' }),
    publicRatings: t.field({ type: [PublicRatingInput], description: 'Notes communautaires' }),
    series: t.string({ description: 'Nom de la série (null pour retirer de la série)' }),
    seriesLabel: t.string({ description: 'Label dans la série' }),
    seriesNumber: t.float({ description: 'Position dans la série' }),
  }),
})
