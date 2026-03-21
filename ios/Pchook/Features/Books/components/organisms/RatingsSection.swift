import SwiftUI

struct RatingsSection: View {
    let publicRatings: [Item]
    let userRating: Int?
    let onAddReview: () -> Void

    var body: some View {
        Section("Notes") {
            if let userRating {
                RatingRow(label: "Moi", score: Double(userRating), maxScore: 5)
            } else {
                Button {
                    onAddReview()
                } label: {
                    Label("Noter", systemImage: "star")
                }
            }

            ForEach(publicRatings) { rating in
                RatingRow(
                    label: rating.source,
                    score: rating.score,
                    maxScore: rating.maxScore,
                    voterCount: rating.voterCount,
                    url: rating.url
                )
            }
        }
    }
}

extension RatingsSection {
    struct Item: Identifiable {
        let source: String
        let score: Double
        let maxScore: Double
        let voterCount: Int
        var url: String?

        var id: String { source }
    }
}

#Preview("Avec notes") {
    List {
        RatingsSection(
            publicRatings: [
                .init(source: "Hardcover", score: 4.12, maxScore: 5, voterCount: 8500, url: "https://hardcover.app/books/neuromancer")
            ],
            userRating: 4,
            onAddReview: {}
        )
    }
}

#Preview("Plusieurs notes publiques") {
    List {
        RatingsSection(
            publicRatings: [
                .init(source: "Hardcover", score: 4.12, maxScore: 5, voterCount: 8500, url: "https://hardcover.app/books/neuromancer"),
                .init(source: "Babelio", score: 4.18, maxScore: 5, voterCount: 125000, url: "https://www.babelio.com")
            ],
            userRating: nil,
            onAddReview: {}
        )
    }
}

#Preview("Sans note publique") {
    List {
        RatingsSection(
            publicRatings: [],
            userRating: 4,
            onAddReview: {}
        )
    }
}
