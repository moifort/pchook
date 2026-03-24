import { builder } from '~/domain/shared/graphql/builder'

// Custom scalars (must be registered before types that reference them)
import '~/domain/shared/graphql/scalars'

// Book domain
import '~/domain/book/infrastructure/graphql/enums'
import '~/domain/book/infrastructure/graphql/types'
import '~/domain/book/infrastructure/graphql/inputs'
import '~/domain/book/infrastructure/graphql/queries'
import '~/domain/book/infrastructure/graphql/mutations'

// Scan domain
import '~/domain/scan/infrastructure/graphql/types'
import '~/domain/scan/infrastructure/graphql/mutations'

// Review domain
import '~/domain/review/infrastructure/graphql/types'
import '~/domain/review/infrastructure/graphql/inputs'
import '~/domain/review/infrastructure/graphql/book-fields'
import '~/domain/review/infrastructure/graphql/mutations'

// Series domain
import '~/domain/series/infrastructure/graphql/types'
import '~/domain/series/infrastructure/graphql/book-fields'
import '~/domain/series/infrastructure/graphql/queries'

// Dashboard domain
import '~/domain/dashboard/infrastructure/graphql/types'
import '~/domain/dashboard/infrastructure/graphql/queries'

// Task domain
import '~/domain/task/infrastructure/graphql/types'
import '~/domain/task/infrastructure/graphql/queries'
import '~/domain/task/infrastructure/graphql/mutations'

// Audible domain
import '~/domain/audible/infrastructure/graphql/types'
import '~/domain/audible/infrastructure/graphql/queries'
import '~/domain/audible/infrastructure/graphql/mutations'

export const schema = builder.toSchema()
