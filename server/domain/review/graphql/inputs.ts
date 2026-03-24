import { builder } from '~/domain/shared/graphql/builder'

export const CreateReviewInput = builder.inputType('CreateReviewInput', {
  description: 'Données pour créer une critique',
  fields: (t) => ({
    rating: t.int({ required: true, description: 'Note personnelle (0-10)' }),
    readDate: t.string({ description: 'Date de lecture (ISO 8601)' }),
    reviewNotes: t.string({ description: 'Notes de lecture' }),
  }),
})
