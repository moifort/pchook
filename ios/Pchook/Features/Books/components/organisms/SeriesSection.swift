import SwiftUI

struct SeriesSection: View {
    let name: String
    var flag: String?
    var rating: Int?
    var isEditing = false
    let currentBookId: String
    let items: [Item]
    let onSelectBook: (String) -> Void
    var onRateSeries: () -> Void = {}

    var body: some View {
        Section {
            if rating == nil || isEditing {
                Button { onRateSeries() } label: {
                    Label("Noter la série", systemImage: "star")
                }
            }
            ForEach(items) { (book: Item) in
                if book.id == currentBookId {
                    seriesRow(book)
                } else {
                    Button { onSelectBook(book.id) } label: { seriesRow(book) }
                        .tint(.primary)
                }
            }
        } header: {
            HStack {
                Text("\(name) \(flag ?? "")".trimmingCharacters(in: .whitespaces))
                Spacer()
                if let rating {
                    if rating == 5 {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    } else {
                        StarRatingView(rating: Double(rating))
                    }
                }
            }
        }
    }

    private func seriesRow(_ book: Item) -> some View {
        HStack {
            Text(verbatim: book.label)
                .font(.subheadline.monospaced())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(uiColor: .systemGray5))
                .clipShape(.rect(cornerRadius: 6))
            Text(book.title)
                .lineLimit(1)
            Spacer()
            if let rating = book.rating {
                if rating == 5 {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                } else {
                    StarRatingView(rating: Double(rating))
                        .font(.caption)
                }
            }
            if book.id == currentBookId {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
                    .font(.caption)
            }
        }
    }
}

extension SeriesSection {
    struct Item: Identifiable {
        let id: String
        let title: String
        let label: String
        let position: Double
        var rating: Int?
    }
}

#Preview("Sans note") {
    List {
        SeriesSection(
            name: "Les Rougon-Macquart",
            flag: "🇫🇷",
            currentBookId: "3",
            items: [
                .init(id: "1", title: "La Fortune des Rougon", label: "1", position: 1, rating: 4),
                .init(id: "2", title: "La Curée", label: "2", position: 2),
                .init(id: "3", title: "L'Assommoir", label: "7", position: 7, rating: 5),
            ],
            onSelectBook: { _ in }
        )
    }
}

#Preview("Avec note") {
    List {
        SeriesSection(
            name: "Fondation",
            rating: 4,
            currentBookId: "1",
            items: [
                .init(id: "1", title: "Fondation", label: "1", position: 1, rating: 4),
                .init(id: "2", title: "Fondation et Empire", label: "2", position: 2, rating: 3),
            ],
            onSelectBook: { _ in }
        )
    }
}

#Preview("Favori") {
    List {
        SeriesSection(
            name: "Le Sorceleur",
            rating: 5,
            currentBookId: "1",
            items: [
                .init(id: "1", title: "Le Dernier Voeu", label: "1", position: 1, rating: 5),
            ],
            onSelectBook: { _ in }
        )
    }
}
