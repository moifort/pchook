import SwiftUI

struct BookDetailHeader: View {
    let title: String
    let authors: String
    let genres: [String]
    let status: BookStatus
    let seriesLabel: String?

    var body: some View {
        Section {
            LabeledInfoRow(title: "Titre", value: title, icon: "book")
            if let seriesLabel {
                LabeledInfoRow(title: "Tome", value: seriesLabel, icon: "number")
            }
            LabeledInfoRow(title: "Auteurs", value: authors, icon: "person.2")
            if !genres.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "tag")
                        .foregroundStyle(.secondary)
                    LabeledContent("Genre", value: genres.joined(separator: " \u{2022} "))
                }
            }
            LabeledInfoRow(title: "Statut", value: status.label, icon: status == .toRead ? "bookmark" : "checkmark.circle")
        }
    }
}

#Preview {
    List {
        BookDetailHeader(
            title: "Neuromancien",
            authors: "William Gibson",
            genres: ["Cyberpunk", "Science-Fiction"],
            status: .toRead,
            seriesLabel: "1"
        )
    }
}
