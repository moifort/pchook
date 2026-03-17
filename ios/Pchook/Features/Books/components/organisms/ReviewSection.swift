import SwiftUI

struct ReviewSection: View {
    let review: Item?
    let onAddReview: () -> Void

    var body: some View {
        Section("Mon avis") {
            if let review {
                StarRatingView(rating: review.rating, font: .body)

                if let readDate = review.readDate {
                    LabeledInfoRow(
                        title: "Lu le",
                        value: readDate.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()),
                        icon: "calendar"
                    )
                }

                if let notes = review.reviewNotes {
                    Label {
                        Text(notes)
                    } icon: {
                        Image(systemName: "text.quote")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Button {
                    onAddReview()
                } label: {
                    Label("Ajouter un avis", systemImage: "plus.circle")
                }
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
    List {
        ReviewSection(
            review: .init(rating: 4, readDate: Date(), reviewNotes: "Excellent roman, tr\u{00E8}s bien \u{00E9}crit."),
            onAddReview: {}
        )
    }
}

#Preview("Sans avis") {
    List {
        ReviewSection(review: nil, onAddReview: {})
    }
}
