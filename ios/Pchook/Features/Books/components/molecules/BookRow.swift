import SwiftUI

struct BookRow: View {
    let title: String
    let flag: String?
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
                HStack(spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(2)
                    if let flag {
                        Text(flag)
                            .font(.subheadline)
                    }
                }
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
            title: "L'Étranger",
            flag: "🇫🇷",
            subtitle: "Albert Camus • Roman • 1 prix",
            rating: 4,
            status: .read
        )
        BookRow(
            title: "Le Petit Prince",
            flag: nil,
            subtitle: "Antoine de Saint-Exupéry • Conte",
            rating: nil,
            status: .toRead
        )
        BookRow(
            title: "Neuromancien",
            flag: "🇬🇧",
            subtitle: "William Gibson • Cyberpunk • 2 prix",
            rating: 5,
            status: .read
        )
    }
}
