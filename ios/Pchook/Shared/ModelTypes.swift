import Foundation

// MARK: - UI Enums

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
    case digital

    var id: String { rawValue }

    var label: String {
        switch self {
        case .pocket: "Poche"
        case .paperback: "Broché"
        case .hardcover: "Relié"
        case .audiobook: "Livre audio"
        case .digital: "E-book"
        }
    }

    init?(apiValue: String?) {
        guard let value = apiValue?.trimmingCharacters(in: .whitespaces).lowercased() else { return nil }
        self.init(rawValue: value)
    }
}

// MARK: - Book

struct Award: Sendable {
    let name: String
    var year: Int?
}

struct PublicRating: Sendable {
    let source: String
    let score: Double
    let maxScore: Double
    let voterCount: Int
    var url: String?
}

struct Book: Identifiable, Sendable {
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
    let narrators: [String]
    var personalNotes: String?
    let status: String
    var readDate: Date?
    let awards: [Award]
    let publicRatings: [PublicRating]
    var importSource: String?
    var externalUrl: String?
    let createdAt: Date
    let updatedAt: Date
}

struct BookListItem: Identifiable, Sendable {
    let id: String
    let title: String
    var coverImageUrl: String?
    let authors: [String]
    var genre: String?
    let status: String
    var estimatedPrice: Double?
    let awards: [Award]
    var rating: Int?
    var language: String?
    var seriesName: String?
    var seriesLabel: String?
    var seriesPosition: Double?
    let createdAt: Date
}

// MARK: - Book Detail

struct SeriesBookEntry: Identifiable, Sendable {
    let id: String
    let title: String
    let label: String
    let position: Double
}

struct SeriesInfo: Sendable {
    let name: String
    let label: String
    let position: Double
    let books: [SeriesBookEntry]
}

struct ReviewInfo: Sendable {
    let bookId: String
    let rating: Int
    var readDate: Date?
    var reviewNotes: String?
    let createdAt: Date
}

struct BookDetailData: Sendable {
    let book: Book
    var coverImageUrl: String?
    var series: SeriesInfo?
    var review: ReviewInfo?
}

// MARK: - Book Preview / Scan

struct BookPreview: Sendable {
    let previewId: String
    let title: String
    let authors: [String]
    var publisher: String?
    var publishedDate: String?
    var pageCount: Int?
    var genre: String?
    var synopsis: String?
    var isbn: String?
    var language: String?
    var format: String?
    var series: String?
    var seriesLabel: String?
    var seriesNumber: Int?
    var translator: String?
    var estimatedPrice: Double?
    var duration: String?
    var narrators: [String]?
    let awards: [Award]
    let publicRatings: [PublicRating]
    var coverImageBase64: String?
}

enum ConfirmResult {
    case created(Book)
    case duplicate(Book)
    case replaced(Book)
}

// MARK: - Request Types

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

struct CreateReviewRequest: Encodable, Sendable {
    let rating: Int
    var readDate: String?
    var reviewNotes: String?
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

// MARK: - Dashboard

struct BookCount: Sendable {
    let total: Int
    let toRead: Int
    let read: Int
}

struct FavoriteBook: Identifiable, Sendable {
    let id: String
    let title: String
    let authors: [String]
    var genre: String?
    let rating: Int
    var readDate: Date?
    var estimatedPrice: Double?
}

struct RecentBook: Identifiable, Sendable {
    let id: String
    let title: String
    let authors: [String]
    var genre: String?
    let createdAt: Date
}

struct RecentAward: Sendable {
    let bookTitle: String
    let authors: [String]
    let awardName: String
    let awardYear: Int
}

struct DashboardData: Sendable {
    let bookCount: BookCount
    let favorites: [FavoriteBook]
    let recentBooks: [RecentBook]
    let recentAwards: [RecentAward]
}

// MARK: - Audible

struct AuthCookie: Sendable {
    let name: String
    let value: String
    let domain: String
}

struct AuthStartResponse: Sendable {
    let loginUrl: String
    let sessionId: String
    let cookies: [AuthCookie]
}

struct AudibleData: Sendable {
    var sync: AudibleSyncData?
    var import_: AudibleImportData?
}

struct AudibleSyncData: Sendable {
    let status: String
    var updatedAt: Date?
    var library: [AudibleItemData]?
    var wishlist: [AudibleWishlistItemData]?
}

struct AudibleImportData: Sendable {
    let status: String
    var updatedAt: Date?
    var taskId: String?
    let importedCount: Int
}

struct AudibleItemData: Identifiable, Sendable {
    let asin: String
    let title: String
    let authors: [String]
    let narrators: [String]
    let durationMinutes: Int
    var publisher: String?
    var language: String?
    var coverUrl: String?
    var finishedAt: Date?
    var importedBookId: String?
    var seriesName: String?
    var seriesPosition: Int?
    var id: String { asin }
}

struct AudibleWishlistItemData: Identifiable, Sendable {
    let asin: String
    let title: String
    let authors: [String]
    var importedBookId: String?
    var id: String { asin }
}

struct ImportTaskState: Sendable {
    let phase: String
    let current: Int
    let total: Int
    let message: String
    var startedAt: Date?
    var completedAt: Date?
}

// MARK: - API

struct APIResponse<T: Decodable>: Decodable {
    let status: Int
    let data: T
}
