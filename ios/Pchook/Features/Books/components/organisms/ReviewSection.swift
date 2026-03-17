import SwiftUI

struct ReviewSection: View {
    let review: Item?
    let personalNotes: String?
    let onAddReview: () -> Void

    var body: some View {
        Section {
            if let personalNotes {
                Label {
                    Text(personalNotes)
                } icon: {
                    Image(systemName: "note.text")
                        .foregroundStyle(.secondary)
                }
            }

            if let review {
                if let readDate = review.readDate {
                    LabeledInfoRow(
                        title: "Lu le",
                        value: readDate.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year()),
                        icon: "calendar"
                    )
                }
            }

            if review == nil {
                Button {
                    onAddReview()
                } label: {
                    Label("Donner mon avis", systemImage: "plus.circle")
                }
                .accessibilityIdentifier("add-review-button")
            }

            if review?.rating == nil {
                Button {
                    onAddReview()
                } label: {
                    Label("Noter", systemImage: "star")
                }
            }
        }
    }
}

extension ReviewSection {
    struct Item {
        let rating: Int?
        let readDate: Date?
    }
}

#Preview("Avec avis et note") {
    List {
        ReviewSection(
            review: .init(rating: 4, readDate: Date()),
            personalNotes: "Excellent roman fondateur du cyberpunk.",
            onAddReview: {}
        )
    }
}

#Preview("Avec avis sans note") {
    List {
        ReviewSection(
            review: .init(rating: nil, readDate: Date()),
            personalNotes: "Notes personnelles.",
            onAddReview: {}
        )
    }
}

#Preview("Sans avis") {
    List {
        ReviewSection(review: nil, personalNotes: nil, onAddReview: {})
    }
}
