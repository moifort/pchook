import SwiftUI

struct AudibleSection: View {
    @Bindable var viewModel: AudibleViewModel

    var body: some View {
        Section {
            if viewModel.isConnected || viewModel.isVerifying {
                connectionRow
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

    // MARK: - Connection

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

    // MARK: - Fetch

    @ViewBuilder
    private var fetchRow: some View {
        if viewModel.isVerifying {
            EmptyView()
        } else if viewModel.isFetching {
            HStack(spacing: 8) {
                ProgressView()
                Text("Récupération des données...")
                    .foregroundStyle(.secondary)
            }
        } else if viewModel.hasFetchedData {
            Label {
                Text("\(viewModel.libraryCount) livres · \(viewModel.wishlistCount) souhaits")
            } icon: {
                Image(systemName: "books.vertical")
            }
            if let lastFetched = viewModel.lastFetchedAt {
                HStack {
                    Label("Dernière mise à jour", systemImage: "clock")
                    Spacer()
                    Text(lastFetched, style: .relative)
                        .foregroundStyle(.secondary)
                }
            }
            Button {
                Task { await viewModel.fetchLibrary() }
            } label: {
                Label("Actualiser les données", systemImage: "arrow.triangle.2.circlepath")
            }
        } else if !viewModel.isImportActive {
            Button {
                Task { await viewModel.fetchLibrary() }
            } label: {
                Label("Récupérer les données Audible", systemImage: "arrow.triangle.2.circlepath")
            }
        }
    }

    // MARK: - Import

    @ViewBuilder
    private var importRow: some View {
        if viewModel.isVerifying || viewModel.isFetching {
            EmptyView()
        } else if let task = viewModel.importTask,
            task.phase == "running" || task.phase == "paused"
        {
            importProgressRow(task)
            Button {
                Task { await viewModel.toggleImportPause() }
            } label: {
                if viewModel.isPausing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text(task.phase == "paused" ? "Reprise..." : "Pause...")
                    }
                } else {
                    Label(
                        task.phase == "paused" ? "Reprendre l'import" : "Mettre en pause",
                        systemImage: task.phase == "paused" ? "play.fill" : "pause.fill"
                    )
                }
            }
            .disabled(viewModel.isPausing || viewModel.isCancelling)
            Button(role: .destructive) {
                Task { await viewModel.cancelImport() }
            } label: {
                if viewModel.isCancelling {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Annulation...")
                    }
                } else {
                    Label("Annuler l'import", systemImage: "xmark.circle")
                }
            }
            .disabled(viewModel.isPausing || viewModel.isCancelling)
        } else if let task = viewModel.importTask, task.phase == "completed" {
            Label("Import terminé", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        } else if viewModel.hasFetchedData {
            Button {
                Task { await viewModel.startImport() }
            } label: {
                Label("Importer dans la bibliothèque", systemImage: "square.and.arrow.down")
            }
        }
    }

    @ViewBuilder
    private func importProgressRow(_ task: ImportTaskState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.phase == "paused" ? "En pause" : task.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if task.total > 0 {
                    Spacer()
                    Text("\(task.current)/\(task.total)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            if task.total > 0 {
                ProgressView(
                    value: Double(task.current),
                    total: Double(task.total)
                )
            } else {
                ProgressView()
            }
        }
    }

    // MARK: - Disconnect

    @ViewBuilder
    private var disconnectButton: some View {
        if !viewModel.isVerifying, !viewModel.isFetching, !viewModel.isImportActive {
            Button(role: .destructive) {
                Task { await viewModel.disconnect() }
            } label: {
                Label("Se déconnecter", systemImage: "person.slash")
            }
        }
    }
}
