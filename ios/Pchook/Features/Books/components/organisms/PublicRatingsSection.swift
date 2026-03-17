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
                    StarRatingView(rating: userRating, font: .body)
                }
            }
            ForEach(ratings) { rating in
                HStack {
                    Text(rating.source)
                    Spacer()
                    StarRatingView(rating: rating.normalizedScore, font: .body)
                    Text("(\(formattedVoterCount(rating.voterCount)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        let score: Int
        let maxScore: Int
        let voterCount: Int

        var id: String { source }

        var normalizedScore: Int {
            guard maxScore > 0 else { return 0 }
            return Int((Double(score) / Double(maxScore) * 5.0).rounded())
        }
    }
}

#Preview {
    List {
        PublicRatingsSection(
            ratings: [
                .init(source: "Goodreads", score: 4, maxScore: 5, voterCount: 125000),
                .init(source: "Babelio", score: 8, maxScore: 10, voterCount: 3200),
            ],
            userRating: 4
        )
    }
}
