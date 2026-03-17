import Foundation

// MARK: - Preview Models

struct ShareBookPreview: Codable, Sendable {
    let previewId: String
    let title: String
    let authors: [String]
    var publisher: String?
    var pageCount: Int?
    var genre: String?
    var synopsis: String?
    var language: String?
    var format: String?
    var series: String?
    var seriesNumber: Int?
    var translator: String?
    var estimatedPrice: Double?
    var awards: [ShareAward]
    var publicRatings: [SharePublicRating]
}

struct ShareAward: Codable, Sendable, Identifiable {
    let name: String
    var year: Int?

    var id: String { "\(name)-\(year ?? 0)" }
}

struct SharePublicRating: Codable, Sendable, Identifiable {
    let source: String
    let score: Double
    let maxScore: Double
    let voterCount: Int

    var id: String { source }

    var normalizedScore: Double {
        guard maxScore > 0 else { return 0 }
        return (score / maxScore * 5.0 * 2).rounded() / 2
    }
}

// MARK: - API

private struct ShareAPIResponse<T: Codable & Sendable>: Codable, Sendable {
    let status: Int
    let data: T
}

private struct AnalyzeURLRequest: Codable, Sendable {
    let url: String
    let description: String?
}

private struct ConfirmRequest: Codable, Sendable {
    let previewId: String
    let status: String
}

enum ShareAPIClient {
    static func analyzeUrl(_ url: URL, description: String?) async throws -> ShareBookPreview {
        let serverURL = SharedConfig.sharedDefaults.string(forKey: SharedConfig.serverURLKey) ?? SharedConfig.defaultURL
        let baseURL = URL(string: serverURL)!
        let endpoint = baseURL.appendingPathComponent("/books/analyze-url")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.apiToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(
            AnalyzeURLRequest(url: url.absoluteString, description: description)
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw ShareError.serverError(statusCode)
        }

        let apiResponse = try JSONDecoder().decode(ShareAPIResponse<ShareBookPreview>.self, from: data)
        return apiResponse.data
    }

    static func confirm(previewId: String, status: String) async throws {
        let serverURL = SharedConfig.sharedDefaults.string(forKey: SharedConfig.serverURLKey) ?? SharedConfig.defaultURL
        let baseURL = URL(string: serverURL)!
        let endpoint = baseURL.appendingPathComponent("/books/confirm")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.apiToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(
            ConfirmRequest(previewId: previewId, status: status)
        )

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) || http.statusCode == 409
        else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw ShareError.serverError(statusCode)
        }
    }
}

enum ShareError: LocalizedError {
    case serverError(Int)
    case noURL

    var errorDescription: String? {
        switch self {
        case .serverError(let code): "Erreur serveur (\(code))"
        case .noURL: "Aucune URL partagée"
        }
    }
}
