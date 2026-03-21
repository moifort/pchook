// Auto-generated from API schemas — do not edit manually
// Run `bun run generate` to regenerate

import Foundation

struct Award: Decodable, Sendable {
    let name: String
    var year: Int?
}

struct PublicRating: Decodable, Sendable {
    let source: String
    let score: Double
    let maxScore: Double
    let voterCount: Int
    var url: String?
}

struct Book: Decodable, Identifiable, Sendable {
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

struct BookPreview: Decodable, Sendable {
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

struct BookListItem: Decodable, Identifiable, Sendable {
    let id: String
    let title: String
    let authors: [String]
    var genre: String?
    let status: String
    var estimatedPrice: Double?
    var language: String?
    let awards: [Award]
    var rating: Int?
    var seriesName: String?
    var seriesLabel: String?
    var seriesPosition: Double?
    let createdAt: Date
}

struct SeriesBookEntry: Decodable, Identifiable, Sendable {
    let id: String
    let title: String
    let label: String
    let position: Double
}

struct SeriesInfo: Decodable, Sendable {
    let name: String
    let label: String
    let position: Double
    let books: [SeriesBookEntry]
}

struct ReviewInfo: Decodable, Sendable {
    let bookId: String
    let rating: Int
    var readDate: Date?
    var reviewNotes: String?
    let createdAt: Date
}

struct BookDetailData: Decodable, Sendable {
    let book: Book
    var coverImageBase64: String?
    var series: SeriesInfo?
    var review: ReviewInfo?
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

struct RecentAward: Decodable, Sendable {
    let bookTitle: String
    let authors: [String]
    let awardName: String
    let awardYear: Int
}

struct DashboardData: Decodable, Sendable {
    let bookCount: BookCount
    let favorites: [FavoriteBook]
    let recentBooks: [RecentBook]
    let recentAwards: [RecentAward]
}

