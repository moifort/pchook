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
            ForEach(ratings) { rating in
                HStack {
                    Text(rating.source)
                    Text("(\(formattedVoterCount(rating.voterCount)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    StarRatingView(rating: rating.normalizedScore, font: .body)
                }
            }
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
                .init(source: "Goodreads", score: 4.18, maxScore: 5, voterCount: 125000),
                .init(source: "Babelio", score: 8.3, maxScore: 10, voterCount: 3200),
            ],
            userRating: 4
        )
    }
}
