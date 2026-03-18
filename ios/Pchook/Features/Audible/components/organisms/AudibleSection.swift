import SwiftUI

struct AudibleSection: View {
    @Bindable var viewModel: AudibleViewModel

    var body: some View {
        Section {
            connectionRow
            if viewModel.isConnected {
                syncRow
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
                if let result = viewModel.lastSyncResult {
                    SyncResultRow(label: "Ajoutés", value: result.newBooksAdded, icon: "plus.circle")
                    SyncResultRow(label: "Doublons", value: result.duplicatesSkipped, icon: "arrow.triangle.2.circlepath")
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
            Text("Les livres seront importés et enrichis automatiquement. Les doublons existants seront mis à jour.")
        }
    }

    @ViewBuilder
    private var connectionRow: some View {
        if viewModel.isConnected {
            Label("Connecté", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
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
    }

    @ViewBuilder
    private var syncRow: some View {
        Button {
            viewModel.requestSync()
        } label: {
            if viewModel.isSyncing {
                HStack {
                    ProgressView()
                    Text("Synchronisation en cours...")
                }
            } else {
                Label("Lancer la synchronisation", systemImage: "arrow.triangle.2.circlepath")
            }
        }
        .disabled(viewModel.isSyncing)
    }
}
