import { builder } from '~/domain/shared/graphql/builder'
import type { SeriesInfo } from '~/read-model/book-detail/types'

const SeriesBookEntryType = builder
  .objectRef<SeriesInfo['books'][number]>('SeriesBookEntry')
  .implement({
    description: "Entrée d'un livre dans une série",
    fields: (t) => ({
      id: t.id({ description: 'Identifiant du livre', resolve: ({ id }) => String(id) }),
      title: t.exposeString('title', { description: 'Titre du livre' }),
      label: t.exposeString('label', { description: 'Label dans la série (ex: Tome 3)' }),
      position: t.exposeInt('position', { description: 'Position dans la série' }),
    }),
  })

export const SeriesInfoType = builder.objectRef<SeriesInfo>('SeriesInfo').implement({
  description: 'Informations sur la série à laquelle appartient un livre',
  fields: (t) => ({
    name: t.exposeString('name', { description: 'Nom de la série' }),
    label: t.exposeString('label', { description: 'Label du livre dans la série' }),
    position: t.exposeInt('position', { description: 'Position du livre dans la série' }),
    books: t.field({
      type: [SeriesBookEntryType],
      description: 'Tous les livres de la série (même langue)',
      resolve: ({ books }) => books,
    }),
  }),
})
