import SwiftUI

struct BookDetailHeader: View {
    let title: String
    let authors: String
    let genres: [String]
    let status: String

    var body: some View {
        Section {
            LabeledInfoRow(title: "Titre", value: title, icon: "book")
            LabeledInfoRow(title: "Auteurs", value: authors, icon: "person.2")
            if !genres.isEmpty {
                LabeledInfoRow(title: "Genre", value: genres.joined(separator: " \u{2022} "), icon: "tag")
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
            status: "to-read"
        )
    }
}
