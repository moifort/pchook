import SwiftUI

struct PublicRatingsSection: View {
    let ratings: [Item]
    let userRating: Int?

    var body: some View {
        Section("Notes") {
            if let userRating {
                HStack {
                    Text("Moi")
                    Spacer()
                    StarRatingView(rating: Double(userRating), font: .body)
                }
            }
            ForEach(ratings.sorted { $0.voterCount > $1.voterCount }) { rating in
                if let url = rating.url.flatMap({ URL(string: $0) }) {
                    Link(destination: url) {
                        ratingRow(rating)
                    }
                } else {
                    ratingRow(rating)
                }
            }
        }
    }

    private func ratingRow(_ rating: Item) -> some View {
        HStack {
            Text(rating.source)
            Text("(\(formattedVoterCount(rating.voterCount)))")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            StarRatingView(rating: rating.normalizedScore, font: .body)
        }
    }

    private func formattedVoterCount(_ count: Int) -> String {
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }
}

extension PublicRatingsSection {
    struct Item: Identifiable {
        let source: String
        let score: Double
        let maxScore: Double
        let voterCount: Int
        var url: String?

        var id: String { source }

        var normalizedScore: Double {
            guard maxScore > 0 else { return 0 }
            return (score / maxScore * 5.0 * 2).rounded() / 2
        }
    }
}

#Preview {
    List {
        PublicRatingsSection(
            ratings: [
                .init(source: "Goodreads", score: 4.18, maxScore: 5, voterCount: 125000, url: "https://www.goodreads.com/book/isbn/9782266320481"),
                .init(source: "Babelio", score: 8.3, maxScore: 10, voterCount: 3200, url: "https://www.babelio.com/isbn/9782266320481"),
            ],
            userRating: 4
        )
    }
}
