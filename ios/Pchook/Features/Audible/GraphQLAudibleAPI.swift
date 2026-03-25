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
        let sync = audible.sync
        let imp = audible.import

        return AudibleData(
            sync: AudibleSyncData(
                status: AudibleSyncStatus(rawValue: sync.status) ?? .disconnected,
                updatedAt: sync.updatedAt.flatMap(GraphQLHelpers.parseISO8601),
                entries: sync.entries.map { entry in
                    AudibleEntryData(
                        item: AudibleItemData(
                            asin: entry.item.asin,
                            title: entry.item.title,
                            authors: entry.item.authors,
                            narrators: entry.item.narrators,
                            durationMinutes: entry.item.durationMinutes,
                            publisher: entry.item.publisher,
                            language: entry.item.language,
                            coverUrl: entry.item.coverUrl,
                            finishedAt: entry.item.finishedAt.flatMap(GraphQLHelpers.parseISO8601),
                            seriesName: entry.item.series?.name,
                            seriesPosition: entry.item.series?.position
                        ),
                        source: entry.source,
                        downloadedAt: GraphQLHelpers.parseISO8601(entry.downloadedAt) ?? Date()
                    )
                }
            ),
            import_: AudibleImportData(
                status: AudibleImportStatus(rawValue: imp.status) ?? .initial,
                updatedAt: imp.updatedAt.flatMap(GraphQLHelpers.parseISO8601),
                taskId: imp.taskId,
                importedCount: imp.importedCount,
                mappings: imp.mappings.map { mapping in
                    AsinBookMappingData(
                        asin: mapping.asin,
                        bookId: mapping.bookId
                    )
                }
            )
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
