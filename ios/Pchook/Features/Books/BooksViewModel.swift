import Foundation

enum BookListMode: String, CaseIterable, Identifiable {
    case all, toRead, series, favorites
    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: "Tous"
        case .toRead: "À lire"
        case .series: "Séries"
        case .favorites: "Favoris"
        }
    }
    var icon: String {
        switch self {
        case .all: "books.vertical"
        case .toRead: "bookmark"
        case .series: "list.number"
        case .favorites: "heart.fill"
        }
    }
    var title: String {
        switch self {
        case .all: "Mes Livres"
        case .toRead: "À lire"
        case .series: "Séries"
        case .favorites: "Favoris"
        }
    }
    var subtitle: String {
        switch self {
        case .all: "Tous vos livres ajoutés"
        case .toRead: "Livres en attente de lecture"
        case .series: "Vos livres regroupés par série"
        case .favorites: "Vos favoris"
        }
    }
}

enum BookSort: String, CaseIterable, Identifiable {
    case createdAt, title, author, genre, myRating, awards
    var id: String { rawValue }
    var label: String {
        switch self {
        case .createdAt: "Date d'ajout"
        case .title: "Titre"
        case .author: "Auteur"
        case .genre: "Genre"
        case .myRating: "Ma note"
        case .awards: "Prix littéraires"
        }
    }
    var icon: String {
        switch self {
        case .createdAt: "clock"
        case .title: "textformat"
        case .author: "person"
        case .genre: "tag"
        case .myRating: "star"
        case .awards: "trophy"
        }
    }
}

@MainActor @Observable
final class BooksViewModel {
    var books: [BookListItem] = []
    var favoriteSeries: [FavoriteSeriesItem] = []
    var isLoading = false
    var isLoadingMore = false
    var hasBooks = false
    var hasMore = false
    var totalCount = 0
    var error: String?
    var sort: BookSort = .createdAt
    var sortDescending = true
    var mode: BookListMode = .all

    private let pageSize = 20

    var isEmpty: Bool {
        books.isEmpty && favoriteSeries.isEmpty
    }

    var usesGrouping: Bool {
        sort != .title || mode == .series
    }

    var groupedBooks: [BookSection] {
        if mode == .series {
            return BookGrouping.groupedBySeries(books: books)
        }
        return BookGrouping.grouped(books: books, sort: sort, descending: sortDescending)
    }

    func subtitle(for book: BookListItem) -> String? {
        if mode == .series {
            let parts: [String?] = [
                book.authors.first,
                book.seriesLabel.map { "Tome \($0)" },
            ]
            let filtered = parts.compactMap { $0 }
            return filtered.isEmpty ? nil : filtered.joined(separator: " • ")
        }

        let parts: [String?] = [
            book.authors.first,
            book.genre?.split(separator: ",").first.map { $0.trimmingCharacters(in: .whitespaces) },
            book.awards.isEmpty ? nil : "\(book.awards.count) prix",
        ]
        let filtered = parts.compactMap { $0 }
        return filtered.isEmpty ? nil : filtered.joined(separator: " • ")
    }

    var navigationSubtitle: String {
        if mode == .favorites {
            let parts = [
                favoriteSeries.isEmpty ? nil : "\(favoriteSeries.count) \(favoriteSeries.count <= 1 ? "série" : "séries")",
                totalCount == 0 ? nil : "\(totalCount) \(totalCount <= 1 ? "livre" : "livres")",
            ].compactMap { $0 }
            return parts.isEmpty ? mode.subtitle : "\(mode.subtitle) · \(parts.joined(separator: ", "))"
        }
        return "\(mode.subtitle) · \(totalCount) \(totalCount <= 1 ? "livre" : "livres")"
    }

    var filterKey: String {
        "\(mode.rawValue)-\(sort.rawValue)-\(sortDescending)"
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            if mode == .favorites {
                async let booksTask = fetchPage(offset: 0)
                async let seriesTask = GraphQLBooksAPI.favoriteSeries()
                let (page, series) = try await (booksTask, seriesTask)
                books = page.items
                totalCount = page.totalCount
                hasMore = page.hasMore
                favoriteSeries = series
            } else {
                favoriteSeries = []
                let page = try await fetchPage(offset: 0)
                books = page.items
                totalCount = page.totalCount
                hasMore = page.hasMore
            }
            if !books.isEmpty || !favoriteSeries.isEmpty { hasBooks = true }
        } catch is CancellationError {
            // Ignored — task cancelled by SwiftUI (e.g. refreshTrigger changed)
        } catch {
            self.error = reportError(error)
        }
        isLoading = false
    }

    func loadMore() async {
        guard !isLoadingMore && hasMore else { return }
        isLoadingMore = true
        do {
            let page = try await fetchPage(offset: books.count)
            books.append(contentsOf: page.items)
            totalCount = page.totalCount
            hasMore = page.hasMore
        } catch is CancellationError {
            // Ignored
        } catch {
            self.error = reportError(error)
        }
        isLoadingMore = false
    }

    private func fetchPage(offset: Int) async throws -> BookListPage {
        var status: String?
        var isFavorite: Bool?
        var hasSeries: Bool?

        switch mode {
        case .all: break
        case .toRead: status = "to-read"
        case .series: hasSeries = true
        case .favorites: isFavorite = true
        }

        return try await GraphQLBooksAPI.list(
            status: status,
            sort: sort.rawValue,
            order: sortDescending ? "desc" : "asc",
            isFavorite: isFavorite,
            hasSeries: hasSeries,
            offset: offset,
            limit: pageSize
        )
    }
}
