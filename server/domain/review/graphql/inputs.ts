import { builder } from '~/domain/shared/graphql/builder'

export const CreateReviewInput = builder.inputType('CreateReviewInput', {
  description: 'Data to create a review',
  fields: (t) => ({
    rating: t.int({ required: true, description: 'Personal rating (0-10)' }),
    readDate: t.string({ description: 'Read date (ISO 8601)' }),
    reviewNotes: t.string({ description: 'Reading notes' }),
  }),
})
