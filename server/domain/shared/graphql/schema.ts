import { builder } from '~/domain/shared/graphql/builder'

// Book domain
import '~/domain/book/graphql/enums'
import '~/domain/book/graphql/types'
import '~/domain/book/graphql/inputs'
import '~/domain/book/graphql/queries'
import '~/domain/book/graphql/mutations'

// Review domain
import '~/domain/review/graphql/types'
import '~/domain/review/graphql/inputs'
import '~/domain/review/graphql/book-fields'
import '~/domain/review/graphql/mutations'

// Series domain
import '~/domain/series/graphql/types'
import '~/domain/series/graphql/book-fields'
import '~/domain/series/graphql/queries'

// Dashboard domain
import '~/domain/dashboard/graphql/types'
import '~/domain/dashboard/graphql/queries'

// Audible domain
import '~/domain/audible/graphql/types'
import '~/domain/audible/graphql/queries'
import '~/domain/audible/graphql/mutations'

export const schema = builder.toSchema()
