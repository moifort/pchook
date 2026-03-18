import SwiftUI

struct AudiblePage: View {
    let refreshTrigger: Int
    @State private var viewModel = AudibleViewModel()

    var body: some View {
        NavigationStack {
            List {
                connectionSection
                if viewModel.isConnected {
                    syncSection
                    statsSection
                }
                if let result = viewModel.lastSyncResult {
                    lastSyncResultSection(result)
                }
            }
            .navigationTitle("Audible")
            .toolbar {
                if viewModel.isConnected {
                    ToolbarItem(placement: .primaryAction) {
                        AsyncToolbarButton(
                            title: "Synchroniser",
                            systemImage: "arrow.triangle.2.circlepath"
                        ) {
                            await viewModel.startSync()
                        }
                    }
                }
            }
            .task(id: refreshTrigger) { await viewModel.checkStatus() }
            .sheet(isPresented: $viewModel.showLogin) {
                AudibleLoginSheet {
                    await viewModel.onLoginComplete()
                }
            }
            .alert("Erreur", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                if let error = viewModel.error {
                    Text(error)
                }
            }
        }
    }

    @ViewBuilder
    private var connectionSection: some View {
        Section {
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
        } header: {
            Text("Compte")
        }
    }

    @ViewBuilder
    private var syncSection: some View {
        Section {
            Button {
                Task { await viewModel.startSync() }
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

    @ViewBuilder
    private var statsSection: some View {
        Section {
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
        } header: {
            Text("Statistiques")
        }
    }

    private func lastSyncResultSection(_ result: SyncResult) -> some View {
        Section {
            SyncResultRow(label: "Livres ajoutés", value: result.newBooksAdded, icon: "plus.circle")
            SyncResultRow(label: "Doublons ignorés", value: result.duplicatesSkipped, icon: "arrow.triangle.2.circlepath")
        } header: {
            Text("Dernière synchronisation")
        }
    }
}

#Preview {
    AudiblePage(refreshTrigger: 0)
}
