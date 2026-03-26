import SwiftUI

struct SearchResultsView: View {
    let results: SearchResultsData
    let onSelectBook: (String) -> Void
    var onSelectSeries: (String) -> Void = { _ in }

    var body: some View {
        List {
            if !results.authors.isEmpty {
                Section("Auteurs") {
                    ForEach(results.authors) { author in
                        Button {
                            onSelectBook(author.firstBookId)
                        } label: {
                            AuthorSearchRow(
                                name: author.name,
                                bookCount: author.bookCount
                            )
                        }
                        .tint(.primary)
                    }
                }
            }

            if !results.series.isEmpty {
                Section("Séries") {
                    ForEach(results.series) { series in
                        Button {
                            onSelectSeries(series.id)
                        } label: {
                            SeriesSearchRow(
                                name: series.name,
                                volumeCount: series.volumeCount,
                                rating: series.rating,
                                languages: series.languages
                            )
                        }
                        .tint(.primary)
                    }
                }
            }

            if !results.books.isEmpty {
                Section("Livres") {
                    ForEach(results.books) { book in
                        Button {
                            onSelectBook(book.id)
                        } label: {
                            BookSearchRow(
                                title: book.title,
                                authors: book.authors.joined(separator: ", "),
                                flag: book.language.flatMap { BookGrouping.flagEmoji(for: $0) },
                                status: book.status
                            )
                        }
                        .tint(.primary)
                    }
                }
            }
        }
    }
}

#Preview {
    SearchResultsView(
        results: SearchResultsData(
            books: [
                BookSearchResultItem(
                    id: "1", title: "Fondation",
                    authors: ["Isaac Asimov"], language: "fr",
                    status: "read", coverImageUrl: nil
                ),
            ],
            series: [
                SeriesSearchResultItem(
                    id: "2", name: "Fondation",
                    volumeCount: 7, rating: 5,
                    languages: ["fr", "en"]
                ),
            ],
            authors: [
                AuthorSearchResultItem(
                    name: "Isaac Asimov",
                    bookCount: 12, firstBookId: "1"
                ),
            ]
        ),
        onSelectBook: { _ in }
    )
}
