import SwiftUI

struct SeriesSection: View {
    let name: String
    let currentPosition: Int
    let items: [Item]
    let onSelectBook: (String) -> Void

    var body: some View {
        Section("S\u{00E9}rie : \(name)") {
            ForEach(items) { (book: Item) in
                if book.position == currentPosition {
                    seriesRow(book)
                } else {
                    Button { onSelectBook(book.id) } label: { seriesRow(book) }
                        .tint(.primary)
                }
            }
        }
    }

    private func seriesRow(_ book: Item) -> some View {
        HStack {
            Text("\(book.position)")
                .font(.subheadline.monospaced())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(uiColor: .systemGray5))
                .clipShape(.rect(cornerRadius: 6))
            Text(book.title)
                .lineLimit(1)
            Spacer()
            if book.position == currentPosition {
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
        let position: Int
    }
}

#Preview {
    List {
        SeriesSection(
            name: "Les Rougon-Macquart",
            currentPosition: 7,
            items: [
                .init(id: "1", title: "La Fortune des Rougon", position: 1),
                .init(id: "2", title: "La Cur\u{00E9}e", position: 2),
                .init(id: "3", title: "L'Assommoir", position: 7),
            ],
            onSelectBook: { _ in }
        )
    }
}
