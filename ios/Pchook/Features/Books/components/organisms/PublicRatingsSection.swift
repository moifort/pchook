import SwiftUI

struct PublicRatingsSection: View {
    let ratings: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes publiques", systemImage: "chart.bar")
                .font(.headline)

            VStack(spacing: 0) {
                ForEach(ratings) { rating in
                    HStack {
                        Text(rating.source)
                            .font(.subheadline)
                        Spacer()
                        Text("\(rating.score)/\(rating.maxScore)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        if rating.voterCount > 0 {
                            Text("(\(formattedVoterCount(rating.voterCount)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                }
            }
            .background(Color(.systemGray6))
            .clipShape(.rect(cornerRadius: 12))
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
    PublicRatingsSection(
        ratings: [
            .init(source: "Goodreads", score: 4, maxScore: 5, voterCount: 125000),
            .init(source: "Babelio", score: 8, maxScore: 10, voterCount: 3200),
        ]
    )
    .padding()
}
