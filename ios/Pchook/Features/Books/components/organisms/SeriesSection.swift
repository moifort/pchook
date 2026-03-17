import SwiftUI

struct SeriesSection: View {
    let name: String
    let position: Int
    let books: [Item]

    var body: some View {
        Section("S\u{00E9}rie : \(name) \u{2014} Tome \(position)") {
            ForEach(books) { book in
                HStack {
                    Text("Tome \(book.position)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .leading)
                    Text(book.title)
                        .lineLimit(1)
                }
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
            position: 7,
            books: [
                .init(id: "1", title: "La Fortune des Rougon", position: 1),
                .init(id: "2", title: "La Cur\u{00E9}e", position: 2),
                .init(id: "3", title: "L'Assommoir", position: 7),
            ]
        )
    }
}
