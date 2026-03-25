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
    var seriesLabel: String?
    var seriesNumber: Int?
    var translator: String?
    var estimatedPrice: Double?
    var duration: String?
    var narrators: [String]?
    var awards: [ShareAward]
}

struct ShareAward: Codable, Sendable, Identifiable {
    let name: String
    var year: Int?

    var id: String { "\(name)-\(year ?? 0)" }
}

// MARK: - Enums

enum ShareBookLanguage: String, CaseIterable, Identifiable {
    case fr
    case en

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fr: "Français"
        case .en: "English"
        }
    }

    init?(apiValue: String?) {
        guard let value = apiValue?.trimmingCharacters(in: .whitespaces).lowercased() else { return nil }
        self.init(rawValue: value)
    }
}

enum ShareBookFormat: String, CaseIterable, Identifiable {
    case pocket
    case paperback
    case hardcover
    case audiobook

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pocket: "Poche"
        case .paperback: "Broché"
        case .hardcover: "Relié"
        case .audiobook: "Livre audio"
        }
    }

    init?(apiValue: String?) {
        guard let value = apiValue?.trimmingCharacters(in: .whitespaces).lowercased() else { return nil }
        self.init(rawValue: value)
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
    let rawText: String?
    let attachmentTypes: [String]?
}

private struct ConfirmRequest: Codable, Sendable {
    let previewId: String
    let status: String
    var overrides: ShareConfirmOverrides?
}

struct ShareConfirmOverrides: Codable, Sendable {
    var title: String?
    var authors: [String]?
    var publisher: String?
    var pageCount: Int?
    var genre: String?
    var synopsis: String?
    var language: String?
    var format: String?
    var translator: String?
    var estimatedPrice: Double?
    var series: String?
    var seriesLabel: String?
    var seriesNumber: Int?
}

enum ShareAPIClient {
    static func analyzeUrl(_ url: URL, description: String?, rawText: String?, attachmentTypes: [String]) async throws -> ShareBookPreview {
        let serverURL = SharedConfig.sharedDefaults.string(forKey: SharedConfig.serverURLKey) ?? SharedConfig.defaultURL
        let baseURL = URL(string: serverURL)!
        let endpoint = baseURL.appendingPathComponent("/books/analyze-url")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.apiToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(
            AnalyzeURLRequest(
                url: url.absoluteString,
                description: description,
                rawText: rawText,
                attachmentTypes: attachmentTypes.isEmpty ? nil : attachmentTypes
            )
        )

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 422 { throw ShareError.extractionFailed }
            throw ShareError.serverError(statusCode)
        }

        let apiResponse = try JSONDecoder().decode(ShareAPIResponse<ShareBookPreview>.self, from: data)
        return apiResponse.data
    }

    static func confirm(previewId: String, status: String, overrides: ShareConfirmOverrides? = nil) async throws {
        let serverURL = SharedConfig.sharedDefaults.string(forKey: SharedConfig.serverURLKey) ?? SharedConfig.defaultURL
        let baseURL = URL(string: serverURL)!
        let endpoint = baseURL.appendingPathComponent("/books/confirm")

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.apiToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(
            ConfirmRequest(previewId: previewId, status: status, overrides: overrides)
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
    case extractionFailed

    var errorDescription: String? {
        switch self {
        case .serverError(let code): "Erreur serveur (\(code))"
        case .noURL: "Aucune URL partagée"
        case .extractionFailed:
            "Impossible d'identifier le livre à partir de ce lien. Essayez depuis une autre source."
        }
    }
}
