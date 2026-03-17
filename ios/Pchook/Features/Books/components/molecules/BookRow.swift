import SwiftUI

struct BookRow: View {
    let title: String
    let authors: String
    let genre: String?
    let rating: Int?
    let status: String
    let awardCount: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                Text(authors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if let genre {
                        ForEach(genre.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }, id: \.self) { subGenre in
                            GenreBadge(genre: subGenre)
                        }
                    }
                    if awardCount > 0 {
                        AwardBadge(count: awardCount)
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
            Spacer()
            if let rating {
                StarRatingView(rating: rating)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    List {
        BookRow(
            title: "L'\u{00C9}tranger",
            authors: "Albert Camus",
            genre: "Roman",
            rating: 4,
            status: "read",
            awardCount: 1
        )
        BookRow(
            title: "Le Petit Prince",
            authors: "Antoine de Saint-Exup\u{00E9}ry",
            genre: "Conte",
            rating: nil,
            status: "to-read",
            awardCount: 0
        )
    }
}
