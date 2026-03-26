import SwiftUI

struct RecommendedBooksSection: View {
    let items: [DashboardBook]
    let onSelect: (String) -> Void

    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { book in
                    Button { onSelect(book.id) } label: {
                        DashboardBookRow(
                            title: book.title,
                            flag: book.language.flatMap { BookGrouping.flagEmoji(for: $0) },
                            subtitle: [book.authors.first, book.genre, book.recommendedBy.map { "par \($0)" }].compactMap { $0 }.joined(separator: " · ")
                        )
                    }
                    .tint(.primary)
                }
            } header: {
                Label("Conseillé", systemImage: "person.badge.star")
            }
        }
    }
}
