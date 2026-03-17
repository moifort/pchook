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
                Text(title)
                    .font(.headline)
                    .lineLimit(2)
                Text(authors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    if let genre, let first = genre.split(separator: ",").first {
                        GenreBadge(genre: first.trimmingCharacters(in: .whitespaces))
                    }
                    if awardCount > 0 {
                        AwardBadge(count: awardCount)
                    }
                }
            }
            Spacer()
            if let rating {
                if rating == 5 {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                } else {
                    StarRatingView(rating: rating)
                }
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
        BookRow(
            title: "Neuromancien",
            authors: "William Gibson",
            genre: "Cyberpunk, Science-Fiction",
            rating: 5,
            status: "read",
            awardCount: 2
        )
    }
}
