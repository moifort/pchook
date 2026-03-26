import SwiftUI

struct BookSearchRow: View {
    let title: String
    let authors: String
    let flag: String?
    let status: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if status == "to-read" {
                Image(systemName: "bookmark.fill")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)
                    if let flag {
                        Text(flag)
                            .font(.subheadline)
                    }
                }
                if !authors.isEmpty {
                    Text(authors)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        BookSearchRow(
            title: "Fondation",
            authors: "Isaac Asimov",
            flag: nil,
            status: "read"
        )
        BookSearchRow(
            title: "Le Petit Prince",
            authors: "Antoine de Saint-Exupéry",
            flag: "🇫🇷",
            status: "to-read"
        )
    }
}
