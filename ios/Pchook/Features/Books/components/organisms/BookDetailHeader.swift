import SwiftUI

struct BookDetailHeader: View {
    let title: String
    let authors: String
    let genres: [String]
    let status: String
    let seriesPosition: Int?

    var body: some View {
        Section {
            LabeledInfoRow(title: "Titre", value: title, icon: "book")
            if let seriesPosition {
                LabeledInfoRow(title: "Tome", value: "\(seriesPosition)", icon: "number")
            }
            LabeledInfoRow(title: "Auteurs", value: authors, icon: "person.2")
            if !genres.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "tag")
                        .foregroundStyle(.secondary)
                    LabeledContent("Genre", value: genres.joined(separator: " \u{2022} "))
                }
            }
            if status == "to-read" {
                LabeledInfoRow(title: "Statut", value: "\u{00C0} lire", icon: "bookmark")
            }
        }
    }
}

#Preview {
    List {
        BookDetailHeader(
            title: "Neuromancien",
            authors: "William Gibson",
            genres: ["Cyberpunk", "Science-Fiction"],
            status: "to-read",
            seriesPosition: 1
        )
    }
}
