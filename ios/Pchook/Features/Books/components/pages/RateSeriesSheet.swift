import SwiftUI

struct RateSeriesSheet: View {
    let seriesId: String
    let seriesName: String
    var initialRating: Int?
    let onSaved: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var rating = 0
    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    InteractiveStarRating(rating: $rating)
                }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(seriesName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer", systemImage: "xmark") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer", systemImage: "checkmark") {
                        Task { await save() }
                    }
                    .disabled(rating == 0 || isSaving)
                }
            }
            .onAppear {
                if let initialRating { rating = initialRating }
            }
        }
    }

    private func save() async {
        guard !isSaving else { return }
        isSaving = true
        error = nil
        do {
            try await GraphQLBooksAPI.rateSeries(id: seriesId, rating: rating)
            await onSaved()
        } catch {
            self.error = reportError(error)
        }
        isSaving = false
    }
}

#Preview {
    RateSeriesSheet(seriesId: "preview-id", seriesName: "Les Rougon-Macquart") {}
}

#Preview("Modification") {
    RateSeriesSheet(seriesId: "preview-id", seriesName: "Fondation", initialRating: 4) {}
}
