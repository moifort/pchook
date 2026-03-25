import SwiftUI

struct BookRow: View {
    let title: String
    let subtitle: String?
    let rating: Int?
    let status: BookStatus

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            if status == .toRead {
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
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if let rating {
                if rating == 5 {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                } else {
                    StarRatingView(rating: Double(rating))
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
            subtitle: "Albert Camus \u{2022} Roman \u{2022} 1 prix",
            rating: 4,
            status: .read
        )
        BookRow(
            title: "Le Petit Prince",
            subtitle: "Antoine de Saint-Exup\u{00E9}ry \u{2022} Conte",
            rating: nil,
            status: .toRead
        )
        BookRow(
            title: "Neuromancien",
            subtitle: "William Gibson \u{2022} Cyberpunk \u{2022} 2 prix",
            rating: 5,
            status: .read
        )
    }
}
