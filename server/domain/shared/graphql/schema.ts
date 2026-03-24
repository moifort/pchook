import { builder } from '~/domain/shared/graphql/builder'

import '~/domain/shared/graphql/types/enums'
import '~/domain/shared/graphql/types/book'
import '~/domain/shared/graphql/types/review'
import '~/domain/shared/graphql/types/series'

import '~/domain/shared/graphql/queries/book'

import '~/domain/shared/graphql/inputs/book'
import '~/domain/shared/graphql/mutations/book'

export const schema = builder.toSchema()
