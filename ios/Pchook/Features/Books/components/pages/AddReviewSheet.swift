import SwiftUI

struct AddReviewSheet: View {
    let bookId: String
    let onSaved: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var rating = 0
    @State private var reviewNotes = ""
    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    InteractiveStarRating(rating: $rating)
                }

                Section("Commentaire (optionnel)") {
                    TextField("Votre avis sur ce livre...", text: $reviewNotes, axis: .vertical)
                        .lineLimit(4...8)
                }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Ajouter un avis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        Task { await save() }
                    }
                    .disabled(rating == 0 || isSaving)
                }
            }
        }
    }

    private func save() async {
        guard !isSaving else { return }
        isSaving = true
        error = nil
        do {
            let formatter = ISO8601DateFormatter()
            let request = CreateReviewRequest(
                rating: rating,
                readDate: formatter.string(from: Date()),
                reviewNotes: reviewNotes.isEmpty ? nil : reviewNotes
            )
            try await BooksAPI.addReview(id: bookId, request)
            await onSaved()
        } catch {
            self.error = reportError(error)
        }
        isSaving = false
    }
}

#Preview {
    AddReviewSheet(bookId: "preview-id") {}
}
