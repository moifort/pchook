import SwiftUI

struct AudibleSection: View {
    @Bindable var viewModel: AudibleViewModel

    var body: some View {
        Section {
            if viewModel.isConnected {
                Label("Connecté", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                SyncResultRow(label: "Bibliothèque", value: viewModel.libraryCount, icon: "books.vertical")
                SyncResultRow(label: "Liste de souhaits", value: viewModel.wishlistCount, icon: "heart")
                if let lastSync = viewModel.lastSyncAt {
                    HStack {
                        Label("Dernière sync", systemImage: "clock")
                        Spacer()
                        Text(lastSync, style: .relative)
                            .foregroundStyle(.secondary)
                    }
                }
                syncRow
                if let result = viewModel.lastSyncResult, !viewModel.isSyncing {
                    SyncResultRow(label: "Ajoutés", value: result.newBooksAdded, icon: "plus.circle")
                    SyncResultRow(label: "Doublons", value: result.duplicatesSkipped, icon: "arrow.triangle.2.circlepath")
                }
                Button(role: .destructive) {
                    Task { await viewModel.disconnect() }
                } label: {
                    Label("Se déconnecter", systemImage: "person.slash")
                }
            } else {
                Button {
                    viewModel.showLogin = true
                } label: {
                    Label("Se connecter à Audible", systemImage: "headphones")
                }
            }
        } header: {
            Label("Audible", systemImage: "headphones")
        }
        .confirmationDialog(
            "Importer depuis Audible",
            isPresented: $viewModel.showSyncConfirmation,
            titleVisibility: .visible
        ) {
            Button("Importer bibliothèque et souhaits") {
                Task { await viewModel.confirmSync() }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Les livres seront importés et enrichis automatiquement. Les doublons existants seront mis à jour.\n\nCette opération peut prendre plusieurs minutes.")
        }
    }

    @ViewBuilder
    private var syncRow: some View {
        if viewModel.isSyncing {
            VStack(alignment: .leading, spacing: 8) {
                if let progress = viewModel.syncProgress {
                    Text(progress.message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if progress.total > 0 {
                        ProgressView(
                            value: Double(progress.current),
                            total: Double(progress.total)
                        )
                    } else {
                        ProgressView()
                    }
                } else {
                    HStack {
                        ProgressView()
                        Text("Démarrage...")
                    }
                }
            }
        } else {
            Button {
                viewModel.requestSync()
            } label: {
                Label("Lancer la synchronisation", systemImage: "arrow.triangle.2.circlepath")
            }
        }
    }
}
