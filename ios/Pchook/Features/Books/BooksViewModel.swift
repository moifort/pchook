import Foundation

enum BookListMode: String, CaseIterable, Identifiable {
    case all, series, favorites
    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: "Tous"
        case .series: "S\u{00E9}ries"
        case .favorites: "Favoris"
        }
    }
    var icon: String {
        switch self {
        case .all: "books.vertical"
        case .series: "text.justify.leading"
        case .favorites: "heart.fill"
        }
    }
    var title: String {
        switch self {
        case .all: "Mes Livres"
        case .series: "S\u{00E9}ries"
        case .favorites: "Favoris"
        }
    }
}

enum BookSort: String, CaseIterable, Identifiable {
    case createdAt, title, author, publicRating, awards
    var id: String { rawValue }
    var label: String {
        switch self {
        case .createdAt: "Date d'ajout"
        case .title: "Titre"
        case .author: "Auteur"
        case .publicRating: "Note publique"
        case .awards: "Prix litt\u{00E9}raires"
        }
    }
    var icon: String {
        switch self {
        case .createdAt: "clock"
        case .title: "textformat"
        case .author: "person"
        case .publicRating: "star"
        case .awards: "medal"
        }
    }
}

enum BookStatusFilter: String, CaseIterable, Identifiable {
    case all
    case toRead = "to-read"
    case read
    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: "Tous"
        case .toRead: "\u{00C0} lire"
        case .read: "Lus"
        }
    }
    var icon: String {
        switch self {
        case .all: "tray.full"
        case .toRead: "bookmark"
        case .read: "checkmark.circle"
        }
    }
}

@MainActor @Observable
final class BooksViewModel {
    var books: [BookListItem] = []
    var isLoading = false
    var hasBooks = false
    var error: String?
    var sort: BookSort = .createdAt
    var sortDescending = true
    var statusFilter: BookStatusFilter = .all
    var genreFilter: String?
    var mode: BookListMode = .all

    var availableGenres: [String] {
        Array(Set(books.compactMap(\.genre))).sorted()
    }

    var displayedBooks: [BookListItem] {
        var result = switch mode {
        case .all: books
        case .series: books.filter { $0.seriesName != nil }
        case .favorites: books.filter { $0.rating == 5 }
        }
        if let genreFilter {
            result = result.filter { $0.genre == genreFilter }
        }
        return result
    }

    var filterKey: String {
        "\(mode.rawValue)-\(sort.rawValue)-\(sortDescending)-\(statusFilter.rawValue)"
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            let status: String? = statusFilter == .all ? nil : statusFilter.rawValue
            let apiSort = sort.rawValue
            books = try await BooksAPI.list(
                status: status,
                sort: apiSort,
                order: sortDescending ? "desc" : "asc"
            )
            if !books.isEmpty { hasBooks = true }
        } catch {
            self.error = reportError(error)
        }
        isLoading = false
    }
}
