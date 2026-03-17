import Foundation

struct ShareBookResult: Codable, Sendable {
    let id: String
    let title: String
    let authors: [String]
    let genre: String?
}

private struct APIResponse<T: Codable & Sendable>: Codable, Sendable {
    let status: Int
    let data: T
}

private struct ImportURLRequest: Codable, Sendable {
    let url: String
}

enum ShareAPIClient {
    static func importUrl(_ url: URL) async throws -> ShareBookResult {
        let serverURL = SharedConfig.sharedDefaults.string(forKey: SharedConfig.serverURLKey)
            ?? SharedConfig.defaultURL
        let baseURL = URL(string: serverURL) ?? URL(string: SharedConfig.defaultURL)!
        let endpoint = baseURL.appendingPathComponent("/books/import-url")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.apiToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(ImportURLRequest(url: url.absoluteString))

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) || http.statusCode == 409 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw ShareError.serverError(statusCode)
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(APIResponse<ShareBookResult>.self, from: data)
        return apiResponse.data
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
