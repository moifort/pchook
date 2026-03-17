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
    case createdAt, title, author, genre, publicRating, awards
    var id: String { rawValue }
    var label: String {
        switch self {
        case .createdAt: "Date d'ajout"
        case .title: "Titre"
        case .author: "Auteur"
        case .genre: "Genre"
        case .publicRating: "Note publique"
        case .awards: "Prix litt\u{00E9}raires"
        }
    }
    var icon: String {
        switch self {
        case .createdAt: "clock"
        case .title: "textformat"
        case .author: "person"
        case .genre: "tag"
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

struct BookSection: Identifiable {
    let title: String
    let items: [SectionedBook]
    var id: String { title }
}

struct SectionedBook: Identifiable {
    let sectionTitle: String
    let book: BookListItem
    var id: String { "\(sectionTitle)|\(book.id)" }
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
    var mode: BookListMode = .all

    var displayedBooks: [BookListItem] {
        switch mode {
        case .all: books
        case .series: books.filter { $0.seriesName != nil }
        case .favorites: books.filter { $0.rating == 5 }
        }
    }

    var usesGrouping: Bool {
        sort == .genre || sort == .publicRating || sort == .awards
    }

    var groupedBooks: [BookSection] {
        let items = displayedBooks
        switch sort {
        case .genre:
            var dict: [String: [BookListItem]] = [:]
            for book in items {
                let genres = book.genre?
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) } ?? ["Sans genre"]
                for genre in genres {
                    dict[genre, default: []].append(book)
                }
            }
            let keys = sortDescending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                BookSection(
                    title: key,
                    items: dict[key]!.map { SectionedBook(sectionTitle: key, book: $0) }
                )
            }

        case .publicRating:
            var dict: [Int: [BookListItem]] = [:]
            for book in items {
                dict[averageNormalizedRating(book.publicRatings), default: []].append(book)
            }
            let keys = sortDescending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                let label = key == 0 ? "Aucune note" : "\(key) \u{00E9}toile\(key > 1 ? "s" : "")"
                return BookSection(
                    title: label,
                    items: dict[key]!.map { SectionedBook(sectionTitle: label, book: $0) }
                )
            }

        case .awards:
            var dict: [Int: [BookListItem]] = [:]
            for book in items {
                dict[book.awards.count, default: []].append(book)
            }
            let keys = sortDescending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                let label = key == 0 ? "Aucun prix" : "\(key) prix"
                return BookSection(
                    title: label,
                    items: dict[key]!.map { SectionedBook(sectionTitle: label, book: $0) }
                )
            }

        default:
            return []
        }
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

    private func averageNormalizedRating(_ ratings: [PublicRating]) -> Int {
        guard !ratings.isEmpty else { return 0 }
        let sum = ratings.reduce(0.0) { acc, rating in
            guard rating.maxScore > 0 else { return acc }
            return acc + (Double(rating.score) / Double(rating.maxScore) * 5.0)
        }
        return Int((sum / Double(ratings.count)).rounded())
    }
}
