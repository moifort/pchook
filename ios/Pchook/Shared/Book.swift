import Foundation

struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let status: Int
    let data: T
}

// MARK: - Book

struct Book: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let authors: [String]
    var publisher: String?
    var publishedDate: Date?
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
    var status: String
    var readDate: Date?
    var awards: [Award]
    var publicRatings: [PublicRating]
    let createdAt: Date
    let updatedAt: Date
}

struct Award: Codable, Sendable {
    let name: String
    var year: Int?
}

struct PublicRating: Codable, Sendable {
    let source: String
    let score: Double
    let maxScore: Double
    let voterCount: Int
}

// MARK: - Book List Item

struct BookListItem: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let authors: [String]
    var genre: String?
    let status: String
    var estimatedPrice: Double?
    let awards: [Award]
    let publicRatings: [PublicRating]
    var rating: Int?
    var seriesName: String?
    var seriesPosition: Int?
    let createdAt: Date
}

// MARK: - Book Detail

struct BookDetailData: Decodable, Sendable {
    let book: Book
    var coverImageBase64: String?
    var series: SeriesInfo?
    var review: ReviewInfo?
    let suggestions: [Suggestion]
}

struct SeriesInfo: Decodable, Sendable {
    let name: String
    let position: Int
    let books: [SeriesBookEntry]
}

struct SeriesBookEntry: Decodable, Identifiable, Sendable {
    let id: String
    let title: String
    let position: Int
}

struct ReviewInfo: Decodable, Sendable {
    let rating: Int
    var readDate: Date?
    var reviewNotes: String?
}

// MARK: - Suggestion

struct Suggestion: Codable, Identifiable, Sendable {
    let id: String
    let sourceBookId: String
    let title: String
    let authors: [String]
    var genre: String?
    var synopsis: String?
    let awards: [Award]
    let publicRatings: [PublicRating]
    let createdAt: Date
}

// MARK: - Series

struct Series: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let createdAt: Date
}

// MARK: - Dashboard

struct DashboardData: Decodable, Sendable {
    let bookCount: BookCount
    let favorites: [FavoriteBook]
    let recentBooks: [RecentBook]
    let recentAwards: [RecentAward]
}

struct BookCount: Decodable, Sendable {
    let total: Int
    let toRead: Int
    let read: Int
}

struct FavoriteBook: Decodable, Identifiable, Sendable {
    let id: String
    let title: String
    let authors: [String]
    var genre: String?
    let rating: Int
    var readDate: Date?
    var estimatedPrice: Double?
}

struct RecentBook: Decodable, Identifiable, Sendable {
    let id: String
    let title: String
    let authors: [String]
    var genre: String?
    let createdAt: Date
}

struct RecentAward: Decodable, Sendable, Identifiable {
    let bookTitle: String
    let authors: [String]
    let awardName: String
    let awardYear: Int

    var id: String { "\(bookTitle)-\(awardName)-\(awardYear)" }
}

// MARK: - Book Preview

struct BookPreview: Codable, Sendable {
    let previewId: String
    let title: String
    let authors: [String]
    var publisher: String?
    var pageCount: Int?
    var genre: String?
    var synopsis: String?
    var isbn: String?
    var language: String?
    var format: String?
    var series: String?
    var seriesNumber: Int?
    var translator: String?
    var estimatedPrice: Double?
    var duration: String?
    var narrators: [String]?
    var awards: [Award]
    var publicRatings: [PublicRating]
    var coverImageBase64: String?
}

// MARK: - Enums

enum BookLanguage: String, CaseIterable, Identifiable {
    case fr = "FR"
    case en = "EN"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fr: "Fran\u{00E7}ais"
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
        case .paperback: "Broch\u{00E9}"
        case .hardcover: "Reli\u{00E9}"
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
}

struct AnalyzeBookRequest: Encodable, Sendable {
    let imageBase64: String
    var ocrText: String?
}

struct ConfirmBookRequest: Encodable, Sendable {
    let previewId: String
    let status: String
    var overrides: ConfirmBookOverrides?
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
    var seriesNumber: Int?
}

struct CreateReviewRequest: Encodable, Sendable {
    let rating: Int
    var readDate: String?
    var reviewNotes: String?
}
