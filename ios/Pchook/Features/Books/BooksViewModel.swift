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
        case .favorites: "Vos livres notés 5 étoiles"
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
    var isLoading = false
    var hasBooks = false
    var error: String?
    var sort: BookSort = .createdAt
    var sortDescending = true
    var mode: BookListMode = .all

    var displayedBooks: [BookListItem] {
        switch mode {
        case .all: books
        case .toRead: books.filter { $0.status == "to-read" }
        case .series: books.filter { $0.seriesName != nil }
        case .favorites: books.filter { $0.rating == 5 }
        }
    }

    func count(for mode: BookListMode) -> Int {
        switch mode {
        case .all: books.count
        case .toRead: books.filter { $0.status == "to-read" }.count
        case .series: Set(books.compactMap { $0.seriesName }).count
        case .favorites: books.filter { $0.rating == 5 }.count
        }
    }

    var usesGrouping: Bool {
        sort != .title || mode == .series
    }

    var groupedBooks: [BookSection] {
        if mode == .series {
            return BookGrouping.groupedBySeries(books: displayedBooks)
        }
        return BookGrouping.grouped(books: displayedBooks, sort: sort, descending: sortDescending)
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
        let count = displayedBooks.count
        return "\(mode.subtitle) · \(count) \(count <= 1 ? "livre" : "livres")"
    }

    var filterKey: String {
        "\(mode.rawValue)-\(sort.rawValue)-\(sortDescending)"
    }

    func load() async {
        isLoading = true
        error = nil
        do {
            let apiSort = sort == .myRating ? "createdAt" : sort.rawValue
            books = try await BooksAPI.list(
                status: nil,
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
