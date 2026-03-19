import SwiftUI

struct AudibleSection: View {
    @Bindable var viewModel: AudibleViewModel

    var body: some View {
        Section {
            if viewModel.isConnected || viewModel.isVerifying {
                connectionRow
                statusRows
                fetchRow
                importRow
                disconnectButton
            } else if viewModel.isCheckingStatus {
                HStack {
                    ProgressView()
                    Text("Chargement...")
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
    }

    // MARK: - Connection status

    @ViewBuilder
    private var connectionRow: some View {
        if viewModel.isVerifying {
            HStack(spacing: 8) {
                ProgressView()
                Text("Vérification de la connexion...")
                    .foregroundStyle(.secondary)
            }
        } else {
            Label("Connecté", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }

    // MARK: - Status counts (from last status check)

    @ViewBuilder
    private var statusRows: some View {
        if !viewModel.isVerifying {
            if viewModel.libraryCount > 0 || viewModel.wishlistCount > 0 {
                SyncResultRow(label: "Bibliothèque", value: viewModel.libraryCount, icon: "books.vertical")
                SyncResultRow(label: "Liste de souhaits", value: viewModel.wishlistCount, icon: "heart")
            }
            if let lastSync = viewModel.lastSyncAt {
                HStack {
                    Label("Dernière sync", systemImage: "clock")
                    Spacer()
                    Text(lastSync, style: .relative)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Fetch step

    @ViewBuilder
    private var fetchRow: some View {
        if viewModel.isFetching {
            progressRow
        } else if viewModel.hasFetchedData {
            Label {
                Text("\(viewModel.libraryCount) livres · \(viewModel.wishlistCount) souhaits")
            } icon: {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        } else if !viewModel.isVerifying, !viewModel.isImporting {
            Button {
                Task { await viewModel.fetch() }
            } label: {
                Label("Synchroniser les données", systemImage: "arrow.triangle.2.circlepath")
            }
        }
    }

    // MARK: - Import step

    @ViewBuilder
    private var importRow: some View {
        if viewModel.isImporting {
            progressRow
        } else if viewModel.hasFetchedData, !viewModel.isFetching {
            Button {
                Task { await viewModel.importBooks() }
            } label: {
                Label("Importer dans la bibliothèque", systemImage: "square.and.arrow.down")
            }
        }
    }

    // MARK: - Progress

    @ViewBuilder
    private var progressRow: some View {
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
    }

    // MARK: - Disconnect

    @ViewBuilder
    private var disconnectButton: some View {
        if !viewModel.isBusy, !viewModel.isVerifying {
            Button(role: .destructive) {
                Task { await viewModel.disconnect() }
            } label: {
                Label("Se déconnecter", systemImage: "person.slash")
            }
        }
    }
}
