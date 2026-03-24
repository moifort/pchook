import { builder } from '~/domain/shared/graphql/builder'

export const BookFormatEnum = builder.enumType('BookFormat', {
  description: 'Format physique ou numérique du livre',
  values: {
    pocket: { description: 'Livre de poche' },
    paperback: { description: 'Broché' },
    hardcover: { description: 'Relié' },
    audiobook: { description: 'Livre audio' },
  } as const,
})

export const BookStatusEnum = builder.enumType('BookStatus', {
  description: "Statut de lecture d'un livre",
  values: {
    TO_READ: { value: 'to-read' as const, description: 'À lire' },
    READ: { value: 'read' as const, description: 'Lu' },
  },
})

export const ImportSourceEnum = builder.enumType('ImportSource', {
  description: "Source d'import du livre",
  values: {
    scan: { description: 'Scan de couverture' },
    isbn: { description: 'Code-barres ISBN' },
    url: { description: 'URL externe' },
    audible: { description: 'Import Audible' },
  } as const,
})

export const BookSortEnum = builder.enumType('BookSort', {
  description: 'Champ de tri pour la liste de livres',
  values: {
    createdAt: { description: "Date d'ajout" },
    title: { description: 'Titre alphabétique' },
    author: { description: "Nom de l'auteur" },
    awards: { description: 'Nombre de prix littéraires' },
    genre: { description: 'Genre littéraire' },
  } as const,
})

export const SortOrderEnum = builder.enumType('SortOrder', {
  description: 'Ordre de tri',
  values: {
    asc: { description: 'Croissant' },
    desc: { description: 'Décroissant' },
  } as const,
})
