import Foundation

struct AuthStartResponse: Decodable, Sendable {
    let loginUrl: String
    let sessionId: String
    let cookies: [AuthCookie]
}

struct AuthCookie: Decodable, Sendable {
    let name: String
    let value: String
    let domain: String
}

struct SyncResult: Decodable, Sendable {
    let libraryCount: Int
    let wishlistCount: Int
    let newBooksAdded: Int
    let duplicatesSkipped: Int
}

struct AudibleStatus: Decodable, Sendable {
    let connected: Bool
    let libraryCount: Int
    let wishlistCount: Int
    let lastSyncAt: Date?
}

struct SyncProgressData: Decodable, Sendable {
    let phase: String
    let current: Int
    let total: Int
    let message: String
}

enum AudibleAPI {
    static func authStart(locale: String = "fr") async throws -> AuthStartResponse {
        let response: APIResponse<AuthStartResponse> = try await APIClient.shared.get(
            "/audible/auth/start",
            query: ["locale": locale]
        )
        return response.data
    }

    static func authCallback(sessionId: String, redirectUrl: String) async throws {
        struct Body: Encodable, Sendable {
            let sessionId: String
            let redirectUrl: String
        }
        struct Result: Decodable, Sendable {
            let success: Bool
        }
        let _: APIResponse<Result> = try await APIClient.shared.post(
            "/audible/auth/callback",
            body: Body(sessionId: sessionId, redirectUrl: redirectUrl)
        )
    }

    static func sync() async throws -> SyncResult {
        struct Empty: Encodable, Sendable {}
        let response: APIResponse<SyncResult> = try await APIClient.shared.post(
            "/audible/sync",
            body: Empty()
        )
        return response.data
    }

    static func status() async throws -> AudibleStatus {
        let response: APIResponse<AudibleStatus> = try await APIClient.shared.get("/audible/status")
        return response.data
    }

    static func syncProgress() async throws -> SyncProgressData {
        let response: APIResponse<SyncProgressData> = try await APIClient.shared.get("/audible/sync/progress")
        return response.data
    }

    static func disconnect() async throws {
        struct Empty: Encodable, Sendable {}
        struct Result: Decodable, Sendable {
            let success: Bool
        }
        let _: APIResponse<Result> = try await APIClient.shared.post(
            "/audible/disconnect",
            body: Empty()
        )
    }
}
