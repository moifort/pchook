import Foundation

enum BookListMode: String, CaseIterable, Identifiable {
    case all, toRead, series, favorites
    var id: String { rawValue }
    var label: String {
        switch self {
        case .all: "Tous"
        case .toRead: "\u{00C0} lire"
        case .series: "S\u{00E9}ries"
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
        case .toRead: "\u{00C0} lire"
        case .series: "S\u{00E9}ries"
        case .favorites: "Favoris"
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
        case .awards: "Prix litt\u{00E9}raires"
        }
    }
    var icon: String {
        switch self {
        case .createdAt: "clock"
        case .title: "textformat"
        case .author: "person"
        case .genre: "tag"
        case .myRating: "star"
        case .awards: "medal"
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
        if mode == .series { return seriesGroupedBooks }
        let items = displayedBooks
        switch sort {
        case .createdAt:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale(identifier: "fr_FR")
            var dict: [String: [BookListItem]] = [:]
            var order: [String] = []
            for book in items {
                let key = formatter.string(from: book.createdAt).capitalized
                if dict[key] == nil { order.append(key) }
                dict[key, default: []].append(book)
            }
            return order.map { key in
                BookSection(
                    title: key,
                    items: dict[key]!.map { SectionedBook(sectionTitle: key, book: $0) }
                )
            }

        case .author:
            var dict: [String: [BookListItem]] = [:]
            for book in items {
                let author = book.authors.first ?? "Auteur inconnu"
                dict[author, default: []].append(book)
            }
            let keys = sortDescending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                BookSection(
                    title: key,
                    items: dict[key]!.map { SectionedBook(sectionTitle: key, book: $0) }
                )
            }

        case .genre:
            var dict: [String: [BookListItem]] = [:]
            for book in items {
                let firstGenre = book.genre?
                    .split(separator: ",")
                    .first
                    .map { $0.trimmingCharacters(in: .whitespaces) } ?? "Sans genre"
                dict[firstGenre, default: []].append(book)
            }
            let keys = sortDescending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                BookSection(
                    title: key,
                    items: dict[key]!.map { SectionedBook(sectionTitle: key, book: $0) }
                )
            }

        case .myRating:
            var dict: [Int: [BookListItem]] = [:]
            for book in items {
                dict[book.rating ?? 0, default: []].append(book)
            }
            let keys = sortDescending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                let label = key == 0 ? "Aucune note" : String(repeating: "\u{2605}", count: key)
                return BookSection(
                    title: label,
                    items: dict[key]!.map { SectionedBook(sectionTitle: label, book: $0) }
                )
            }

        case .awards:
            var dict: [String: [BookListItem]] = [:]
            for book in items {
                if book.awards.isEmpty {
                    dict["Aucun prix", default: []].append(book)
                } else {
                    for award in book.awards {
                        dict[award.name, default: []].append(book)
                    }
                }
            }
            let keys = sortDescending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                BookSection(
                    title: key,
                    items: dict[key]!.map { SectionedBook(sectionTitle: key, book: $0) }
                )
            }

        case .title:
            return []
        }
    }

    private var seriesGroupedBooks: [BookSection] {
        var dict: [String: [BookListItem]] = [:]
        for book in displayedBooks {
            let key = book.seriesName ?? ""
            dict[key, default: []].append(book)
        }
        return dict.keys.sorted().map { key in
            let sorted = dict[key]!.sorted { ($0.seriesPosition ?? 0) < ($1.seriesPosition ?? 0) }
            let sectionTitle = key
            return BookSection(
                title: sectionTitle,
                items: sorted.map { SectionedBook(sectionTitle: sectionTitle, book: $0) }
            )
        }
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
