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

struct AudibleStatus: Decodable, Sendable {
    let connected: Bool
    let libraryCount: Int
    let wishlistCount: Int
    let lastSyncAt: Date?
    let rawItemCount: Int
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

    static func syncVerify() async throws {
        struct Empty: Encodable, Sendable {}
        struct Result: Decodable, Sendable {
            let verified: Bool
        }
        let _: APIResponse<Result> = try await APIClient.shared.post(
            "/audible/sync/verify",
            body: Empty()
        )
    }

    static func syncFetch() async throws {
        struct Empty: Encodable, Sendable {}
        struct Result: Decodable, Sendable { let started: Bool }
        let _: APIResponse<Result> = try await APIClient.shared.post(
            "/audible/sync/fetch",
            body: Empty()
        )
    }

    static func syncImport() async throws {
        struct Empty: Encodable, Sendable {}
        struct Result: Decodable, Sendable { let started: Bool }
        let _: APIResponse<Result> = try await APIClient.shared.post(
            "/audible/sync/import",
            body: Empty()
        )
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
