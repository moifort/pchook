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
    var subtitle: String {
        switch self {
        case .all: "Tous vos livres ajout\u{00E9}s"
        case .toRead: "Livres en attente de lecture"
        case .series: "Vos livres regroup\u{00E9}s par s\u{00E9}rie"
        case .favorites: "Vos livres not\u{00E9}s 5 \u{00E9}toiles"
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
        case .awards: "trophy"
        }
    }
}

struct BookSection: Identifiable {
    let title: String
    var flag: String?
    let items: [SectionedBook]
    var id: String { title + (flag ?? "") }
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
        var dict: [String: (seriesName: String, language: String?, books: [BookListItem])] = [:]
        for book in displayedBooks {
            let seriesName = book.seriesName ?? ""
            let key = "\(seriesName)\0\(book.language ?? "")"
            var entry = dict[key] ?? (seriesName: seriesName, language: book.language, books: [])
            entry.books.append(book)
            dict[key] = entry
        }
        return dict.keys.sorted().map { key in
            let entry = dict[key]!
            let sorted = entry.books.sorted { ($0.seriesPosition ?? 0) < ($1.seriesPosition ?? 0) }
            let sectionTitle = entry.seriesName
            return BookSection(
                title: sectionTitle,
                flag: entry.language.flatMap { Self.flagEmoji(for: $0) },
                items: sorted.map { SectionedBook(sectionTitle: sectionTitle, book: $0) }
            )
        }
    }

    private static func flagEmoji(for languageCode: String) -> String? {
        let countryCode: String? = switch languageCode.uppercased() {
        case "FR": "FR"
        case "EN": "GB"
        case "ES": "ES"
        case "DE": "DE"
        case "IT": "IT"
        case "PT": "PT"
        case "JA": "JP"
        case "ZH": "CN"
        case "KO": "KR"
        case "RU": "RU"
        default: nil
        }
        guard let code = countryCode else { return nil }
        return code.unicodeScalars.map { String(UnicodeScalar(127397 + $0.value)!) }.joined()
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
