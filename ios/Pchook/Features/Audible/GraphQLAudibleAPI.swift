import Apollo
import Foundation

enum GraphQLAudibleAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func authStart(locale: String = "fr") async throws -> AuthStartResponse {
        let mutation = PchookGraphQL.AudibleAuthStartMutation(locale: .some(locale))
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)

        let response = data.audibleAuthStart
        return AuthStartResponse(
            loginUrl: response.loginUrl,
            sessionId: response.sessionId,
            cookies: response.cookies.map { cookie in
                AuthCookie(
                    name: cookie.name,
                    value: cookie.value,
                    domain: cookie.domain
                )
            }
        )
    }

    static func authCallback(sessionId: String, redirectUrl: String) async throws {
        let mutation = PchookGraphQL.AudibleAuthCallbackMutation(
            sessionId: sessionId,
            redirectUrl: redirectUrl
        )
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func syncVerify() async throws {
        let mutation = PchookGraphQL.AudibleSyncVerifyMutation()
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func syncFetch() async throws {
        let mutation = PchookGraphQL.AudibleSyncFetchMutation()
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func status() async throws -> AudibleData {
        let query = PchookGraphQL.AudibleQuery()
        let data = try await GraphQLHelpers.fetch(client, query: query)

        let audible = data.audible
        return AudibleData(
            sync: audible.sync.map { sync in
                AudibleSyncData(
                    status: sync.status.rawValue,
                    updatedAt: sync.updatedAt.flatMap(GraphQLHelpers.parseISO8601),
                    library: sync.library?.map { item in
                        AudibleItemData(
                            asin: item.asin,
                            title: item.title,
                            authors: item.authors,
                            narrators: item.narrators,
                            durationMinutes: item.durationMinutes,
                            publisher: item.publisher,
                            language: item.language,
                            coverUrl: item.coverUrl,
                            finishedAt: item.finishedAt.flatMap(GraphQLHelpers.parseISO8601),
                            importedBookId: item.importedBookId,
                            seriesName: item.series?.name,
                            seriesPosition: item.series?.position
                        )
                    },
                    wishlist: sync.wishlist?.map { item in
                        AudibleWishlistItemData(
                            asin: item.asin,
                            title: item.title,
                            authors: item.authors,
                            importedBookId: item.importedBookId
                        )
                    }
                )
            },
            import_: audible.import.map { imp in
                AudibleImportData(
                    status: imp.status.rawValue,
                    updatedAt: imp.updatedAt.flatMap(GraphQLHelpers.parseISO8601),
                    taskId: imp.taskId,
                    importedCount: imp.importedCount
                )
            }
        )
    }

    static func importStart() async throws {
        let mutation = PchookGraphQL.AudibleImportStartMutation()
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func disconnect() async throws {
        let mutation = PchookGraphQL.AudibleDisconnectMutation()
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }
}
