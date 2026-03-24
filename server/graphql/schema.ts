import { builder } from '~/graphql/builder'

import '~/graphql/types/enums'
import '~/graphql/types/book'
import '~/graphql/types/review'
import '~/graphql/types/series'

import '~/graphql/queries/book'

import '~/graphql/inputs/book'
import '~/graphql/mutations/book'

export const schema = builder.toSchema()
