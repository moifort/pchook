import Apollo
import Foundation

enum GraphQLAudibleAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func authStart(locale: String = "fr") async throws -> AuthStartResponse {
        let mutation = PchookGraphQL.AudibleAuthStartMutation(locale: .some(locale))
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)

        let response = data.audibleAuthStart
        return AuthStartResponse(
            loginUrl: response.loginUrl ?? "",
            sessionId: response.sessionId ?? "",
            cookies: (response.cookies ?? []).map { cookie in
                AuthCookie(
                    name: cookie.name ?? "",
                    value: cookie.value ?? "",
                    domain: cookie.domain ?? ""
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

    static func status() async throws -> AudibleStatus {
        let query = PchookGraphQL.AudibleSyncQuery()
        let data = try await GraphQLHelpers.fetch(client, query: query)

        let sync = data.audibleSync
        return AudibleStatus(
            connected: sync.connected,
            fetchInProgress: sync.fetchInProgress,
            libraryCount: sync.libraryCount,
            wishlistCount: sync.wishlistCount,
            lastSyncAt: sync.lastSyncAt.flatMap(GraphQLHelpers.parseISO8601),
            lastFetchedAt: sync.lastFetchedAt.flatMap(GraphQLHelpers.parseISO8601),
            rawItemCount: sync.rawItemCount,
            importTaskId: sync.importTaskId
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
