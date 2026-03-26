import SwiftUI

struct FavoriteSeriesSection: View {
    let items: [DashboardSeries]
    let onSelect: (String) -> Void

    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { series in
                    Button { if let bookId = series.firstBookId { onSelect(bookId) } } label: {
                        DashboardBookRow(
                            title: series.name,
                            flag: series.language.flatMap { BookGrouping.flagEmoji(for: $0) },
                            subtitle: [series.authors.first, "\(series.volumeCount) \(series.volumeCount <= 1 ? "tome" : "tomes")"].compactMap { $0 }.joined(separator: " · ")
                        )
                    }
                    .tint(.primary)
                }
            } header: {
                Label("Séries favorites", systemImage: "list.number")
            }
        }
    }
}
