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
        let query = PchookGraphQL.AudibleStatusQuery()
        let data = try await GraphQLHelpers.fetch(client, query: query)

        let status = data.audibleStatus
        let task = status.importTask
        return AudibleStatus(
            connected: status.connected,
            fetchInProgress: status.fetchInProgress,
            libraryCount: status.libraryCount,
            wishlistCount: status.wishlistCount,
            lastSyncAt: status.lastSyncAt.flatMap(GraphQLHelpers.parseISO8601),
            lastFetchedAt: status.lastFetchedAt.flatMap(GraphQLHelpers.parseISO8601),
            rawItemCount: status.rawItemCount,
            importTask: ImportTaskState(
                phase: task.phase ?? "idle",
                current: task.current,
                total: task.total,
                message: task.message ?? "",
                startedAt: task.startedAt.flatMap(GraphQLHelpers.parseISO8601),
                completedAt: task.completedAt.flatMap(GraphQLHelpers.parseISO8601)
            )
        )
    }

    static func importStart() async throws {
        let mutation = PchookGraphQL.AudibleImportStartMutation()
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func importState() async throws -> ImportTaskState {
        let query = PchookGraphQL.ImportStateQuery()
        let data = try await GraphQLHelpers.fetch(client, query: query)
        let task = data.importState
        return ImportTaskState(
            phase: task.phase ?? "idle",
            current: task.current,
            total: task.total,
            message: task.message ?? "",
            startedAt: task.startedAt.flatMap(GraphQLHelpers.parseISO8601),
            completedAt: task.completedAt.flatMap(GraphQLHelpers.parseISO8601)
        )
    }

    static func importPause() async throws -> Bool {
        let mutation = PchookGraphQL.AudibleImportPauseMutation()
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)
        return data.audibleImportPause ?? true
    }

    static func importCancel() async throws {
        let mutation = PchookGraphQL.AudibleImportCancelMutation()
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func disconnect() async throws {
        let mutation = PchookGraphQL.AudibleDisconnectMutation()
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }
}
