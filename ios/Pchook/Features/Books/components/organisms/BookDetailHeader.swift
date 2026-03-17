import SwiftUI

struct BookDetailHeader: View {
    let title: String
    let authors: String
    let genres: [String]
    let status: String

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(authors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    ForEach(genres, id: \.self) { genre in
                        GenreBadge(genre: genre)
                    }
                    if status == "to-read" {
                        Text("\u{00C0} lire")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(.capsule)
                    }
                }
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
