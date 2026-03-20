import Foundation

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

enum BookGrouping {
    static func grouped(books: [BookListItem], sort: BookSort, descending: Bool) -> [BookSection] {
        switch sort {
        case .createdAt:
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale(identifier: "fr_FR")
            var dict: [String: [BookListItem]] = [:]
            var order: [String] = []
            for book in books {
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
            for book in books {
                let author = book.authors.first ?? "Auteur inconnu"
                dict[author, default: []].append(book)
            }
            let keys = descending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                BookSection(
                    title: key,
                    items: dict[key]!.map { SectionedBook(sectionTitle: key, book: $0) }
                )
            }

        case .genre:
            var dict: [String: [BookListItem]] = [:]
            for book in books {
                let firstGenre = book.genre?
                    .split(separator: ",")
                    .first
                    .map { $0.trimmingCharacters(in: .whitespaces) } ?? "Sans genre"
                dict[firstGenre, default: []].append(book)
            }
            let keys = descending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                BookSection(
                    title: key,
                    items: dict[key]!.map { SectionedBook(sectionTitle: key, book: $0) }
                )
            }

        case .myRating:
            var dict: [Int: [BookListItem]] = [:]
            for book in books {
                dict[book.rating ?? 0, default: []].append(book)
            }
            let keys = descending ? dict.keys.sorted(by: >) : dict.keys.sorted()
            return keys.map { key in
                let label = key == 0 ? "Aucune note" : String(repeating: "★", count: key)
                return BookSection(
                    title: label,
                    items: dict[key]!.map { SectionedBook(sectionTitle: label, book: $0) }
                )
            }

        case .awards:
            var dict: [String: [BookListItem]] = [:]
            for book in books {
                if book.awards.isEmpty {
                    dict["Aucun prix", default: []].append(book)
                } else {
                    for award in book.awards {
                        dict[award.name, default: []].append(book)
                    }
                }
            }
            let keys = descending ? dict.keys.sorted(by: >) : dict.keys.sorted()
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

    static func groupedBySeries(books: [BookListItem]) -> [BookSection] {
        var dict: [String: (seriesName: String, flag: String?, books: [BookListItem])] = [:]
        for book in books {
            let seriesName = book.seriesName ?? ""
            let flag = book.language.flatMap { flagEmoji(for: $0) }
            let key = "\(seriesName)\0\(flag ?? "")"
            var entry = dict[key] ?? (seriesName: seriesName, flag: flag, books: [])
            entry.books.append(book)
            dict[key] = entry
        }
        return dict.keys.sorted().map { key in
            let entry = dict[key]!
            let sorted = entry.books.sorted { ($0.seriesPosition ?? 0) < ($1.seriesPosition ?? 0) }
            let sectionTitle = entry.seriesName
            return BookSection(
                title: sectionTitle,
                flag: entry.flag,
                items: sorted.map { SectionedBook(sectionTitle: sectionTitle, book: $0) }
            )
        }
    }

    static func flagEmoji(for language: String) -> String? {
        let countryCode: String? = switch language.lowercased() {
        case "fr", "french", "français": "FR"
        case "en", "english", "anglais": "GB"
        case "es", "spanish", "espagnol": "ES"
        case "de", "german", "allemand": "DE"
        case "it", "italian", "italien": "IT"
        case "pt", "portuguese", "portugais": "PT"
        case "ja", "japanese", "japonais": "JP"
        case "zh", "chinese", "chinois": "CN"
        case "ko", "korean", "coréen": "KR"
        case "ru", "russian", "russe": "RU"
        default: nil
        }
        guard let code = countryCode else { return nil }
        return code.unicodeScalars.map { String(UnicodeScalar(127397 + $0.value)!) }.joined()
    }
}
