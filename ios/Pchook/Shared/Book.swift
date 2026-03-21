import Foundation

struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let status: Int
    let data: T
}

// MARK: - Enums

enum BookLanguage: String, CaseIterable, Identifiable {
    case fr = "FR"
    case en = "EN"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fr: "Français"
        case .en: "English"
        }
    }

    init?(apiValue: String?) {
        guard let value = apiValue?.trimmingCharacters(in: .whitespaces).uppercased() else { return nil }
        self.init(rawValue: value)
    }
}

enum BookFormatOption: String, CaseIterable, Identifiable {
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

// MARK: - Requests

struct UpdateBookRequest: Encodable, Sendable {
    var title: String?
    var authors: [String]?
    var publisher: String?
    var publishedDate: String?
    var pageCount: Int?
    var genre: String?
    var synopsis: String?
    var isbn: String?
    var language: String?
    var format: String?
    var translator: String?
    var estimatedPrice: Double?
    var duration: String?
    var narrators: [String]?
    var personalNotes: String?
    var status: String?
    var readDate: String?
    var series: String?
    var seriesLabel: String?
    var seriesNumber: Int?
}

struct AnalyzeBookRequest: Encodable, Sendable {
    let imageBase64: String
    var ocrText: String?
}

struct ConfirmBookRequest: Encodable, Sendable {
    let previewId: String
    let status: String
    var overrides: ConfirmBookOverrides?
    var replaceBookId: String?
}

struct ConfirmBookOverrides: Encodable, Sendable {
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

struct CreateReviewRequest: Encodable, Sendable {
    let rating: Int
    var readDate: String?
    var reviewNotes: String?
}
