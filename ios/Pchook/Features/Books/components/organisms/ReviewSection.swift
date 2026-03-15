import SwiftUI

struct ReviewSection: View {
    let review: Item?
    let onAddReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Mon avis", systemImage: "star.bubble")
                .font(.headline)

            if let review {
                VStack(alignment: .leading, spacing: 8) {
                    StarRatingView(rating: review.rating, font: .body)

                    if let readDate = review.readDate {
                        Text("Lu le \(readDate.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let notes = review.reviewNotes {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(.rect(cornerRadius: 12))
            } else {
                Button {
                    onAddReview()
                } label: {
                    Label("Ajouter un avis", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("add-review-button")
            }
        }
    }
}

extension ReviewSection {
    struct Item {
        let rating: Int
        let readDate: Date?
        let reviewNotes: String?
    }
}

#Preview("Avec avis") {
    ReviewSection(
        review: .init(rating: 4, readDate: Date(), reviewNotes: "Excellent roman, tr\u{00E8}s bien \u{00E9}crit."),
        onAddReview: {}
    )
    .padding()
}

#Preview("Sans avis") {
    ReviewSection(review: nil, onAddReview: {})
        .padding()
}
