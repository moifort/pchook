import SwiftUI

struct SeriesSection: View {
    let name: String
    let position: Int
    let books: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("S\u{00E9}rie : \(name)", systemImage: "text.justify.leading")
                    .font(.headline)
                Spacer()
                Text("Tome \(position)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(books) { book in
                    HStack {
                        Text("Tome \(book.position)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 60, alignment: .leading)
                        Text(book.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 14)
                }
            }
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 12))
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
    SeriesSection(
        name: "Les Rougon-Macquart",
        position: 7,
        books: [
            .init(id: "1", title: "La Fortune des Rougon", position: 1),
            .init(id: "2", title: "La Cur\u{00E9}e", position: 2),
            .init(id: "3", title: "L'Assommoir", position: 7),
        ]
    )
    .padding()
}
