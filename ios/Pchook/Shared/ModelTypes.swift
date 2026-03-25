import Foundation

// MARK: - Enums (aligned with GraphQL schema)

enum BookStatus: String, Sendable, CaseIterable, Identifiable {
    case read
    case toRead = "to-read"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .read: "Lu"
        case .toRead: "À lire"
        }
    }
}

enum BookFormat: String, Sendable, CaseIterable, Identifiable {
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

enum ImportSource: String, Sendable {
    case scan
    case isbn
    case url
    case audible

    var label: String {
        switch self {
        case .scan: "Scan couverture"
        case .isbn: "Code ISBN"
        case .url: "Lien partagé"
        case .audible: "Audible"
        }
    }

    var icon: String {
        switch self {
        case .scan: "camera"
        case .isbn: "barcode"
        case .url: "link"
        case .audible: "headphones"
        }
    }
}

enum AudibleSyncStatus: String, Sendable {
    case disconnected
    case connected
    case fetching
    case fetched
}

enum TaskPhase: String, Sendable {
    case idle
    case running
    case paused
    case cancelled
    case completed
    case failed

    var isTerminal: Bool {
        switch self {
        case .idle, .completed, .cancelled, .failed: true
        case .running, .paused: false
        }
    }
}

// MARK: - UI Enums (picker subsets)

enum BookLanguage: String, CaseIterable, Identifiable {
    case fr
    case en
    case es
    case de
    case it
    case pt

    var id: String { rawValue }

    var label: String {
        switch self {
        case .fr: "Français"
        case .en: "English"
        case .es: "Español"
        case .de: "Deutsch"
        case .it: "Italiano"
        case .pt: "Português"
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
    var format: BookFormat?
    var translator: String?
    var estimatedPrice: Double?
    var durationMinutes: Int?
    let narrators: [String]
    var personalNotes: String?
    let status: BookStatus
    var readDate: Date?
    let awards: [Award]
    let publicRatings: [PublicRating]
    var importSource: ImportSource?
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
    let status: BookStatus
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

struct SeriesVolume: Identifiable, Sendable {
    let id: String
    let title: String
    let label: String
    let position: Double
}

struct Series: Sendable {
    let id: String
    let name: String
    let volumes: [SeriesVolume]
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
    var series: Series?
    var seriesVolume: SeriesVolume?
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
    var durationMinutes: Int?
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
    let sync: AudibleSyncData
    let import_: AudibleImportData
}

struct AudibleSyncData: Sendable {
    let status: AudibleSyncStatus
    var updatedAt: Date?
    let libraryCount: Int
    let wishlistCount: Int
}

struct AudibleImportData: Sendable {
    let importedCount: Int
    let totalCount: Int
    let delta: Int
    let status: TaskPhase
    let current: Int
    let total: Int
    let message: String
    var startedAt: Date?
    var completedAt: Date?
}



struct ImportTaskState: Sendable {
    let status: TaskPhase
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
