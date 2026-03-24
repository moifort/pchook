import { builder } from '~/domain/shared/graphql/builder'

import '~/domain/book/graphql/enums'
import '~/domain/book/graphql/types'
import '~/domain/review/graphql/types'
import '~/domain/series/graphql/types'

import '~/domain/book/graphql/queries'

import '~/domain/book/graphql/inputs'
import '~/domain/book/graphql/mutations'

export const schema = builder.toSchema()
