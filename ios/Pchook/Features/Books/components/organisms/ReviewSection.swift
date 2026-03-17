import SwiftUI

struct ReviewSection: View {
    let review: Item?
    let personalNotes: String?
    let status: String
    let onAddReview: () -> Void

    var body: some View {
        Section {
            if status == "to-read" {
                LabeledInfoRow(title: "Statut", value: "\u{00C0} lire", icon: "bookmark")
            } else {
                LabeledInfoRow(title: "Statut", value: "Lu", icon: "checkmark.circle")
            }

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
        }
    }
}

extension ReviewSection {
    struct Item {
        let rating: Int
        let readDate: Date?
    }
}

#Preview("Avec avis") {
    List {
        ReviewSection(
            review: .init(rating: 4, readDate: Date()),
            personalNotes: "Excellent roman fondateur du cyberpunk.",
            status: "read",
            onAddReview: {}
        )
    }
}

#Preview("Sans avis") {
    List {
        ReviewSection(review: nil, personalNotes: nil, status: "to-read", onAddReview: {})
    }
}
