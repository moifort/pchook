import SwiftUI

struct SeriesEditForm: View {
    let initialName: String
    var seriesRating: Int?
    let onSave: (String) async throws -> Void
    let onCancel: () -> Void
    var onRateSeries: () -> Void = {}

    @State private var name: String
    @State private var isSaving = false
    @State private var saveError: String?

    init(
        initialName: String,
        seriesRating: Int? = nil,
        onSave: @escaping (String) async throws -> Void,
        onCancel: @escaping () -> Void,
        onRateSeries: @escaping () -> Void = {}
    ) {
        self.initialName = initialName
        self.seriesRating = seriesRating
        self.onSave = onSave
        self.onCancel = onCancel
        self.onRateSeries = onRateSeries
        _name = State(initialValue: initialName)
    }

    var body: some View {
        Form {
            Section("Informations") {
                LabeledContent {
                    TextField("Nom de la série", text: $name)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Label("Nom", systemImage: "list.number")
                }
            }

            Section("Note") {
                Button { onRateSeries() } label: {
                    HStack {
                        Label("Noter la série", systemImage: "star")
                        Spacer()
                        if let seriesRating {
                            if seriesRating == 5 {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                            } else {
                                StarRatingView(rating: Double(seriesRating))
                            }
                        }
                    }
                }
                .tint(.primary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler", systemImage: "xmark") {
                    onCancel()
                }
                .disabled(isSaving)
            }
            ToolbarItem(placement: .confirmationAction) {
                if isSaving {
                    ProgressView()
                } else {
                    Button("Enregistrer", systemImage: "checkmark") {
                        Task { await save() }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .alert("Erreur", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
    }

    private func save() async {
        guard !isSaving else { return }
        isSaving = true
        do {
            try await onSave(name.trimmingCharacters(in: .whitespaces))
        } catch {
            saveError = reportError(error)
        }
        isSaving = false
    }
}

#Preview {
    NavigationStack {
        SeriesEditForm(
            initialName: "Les Rougon-Macquart",
            seriesRating: 4,
            onSave: { _ in },
            onCancel: {}
        )
    }
}

#Preview("Sans note") {
    NavigationStack {
        SeriesEditForm(
            initialName: "Fondation",
            onSave: { _ in },
            onCancel: {}
        )
    }
}
