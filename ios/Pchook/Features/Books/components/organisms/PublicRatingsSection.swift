import SwiftUI

struct PublicRatingsSection: View {
    let ratings: [Item]

    var body: some View {
        Section("Notes publiques") {
            ForEach(ratings) { rating in
                HStack {
                    Text(rating.source)
                    Spacer()
                    Text("\(rating.score)/\(rating.maxScore)")
                        .fontWeight(.semibold)
                    if rating.voterCount > 0 {
                        Text("(\(formattedVoterCount(rating.voterCount)))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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
    }
}

#Preview {
    List {
        PublicRatingsSection(
            ratings: [
                .init(source: "Goodreads", score: 4, maxScore: 5, voterCount: 125000),
                .init(source: "Babelio", score: 8, maxScore: 10, voterCount: 3200),
            ]
        )
    }
}
