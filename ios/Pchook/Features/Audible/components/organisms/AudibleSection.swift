import SwiftUI

struct AudibleSection: View {
    let state: State
    let onConnect: () -> Void
    let onFetch: () async -> Void
    let onImport: () async -> Void
    let onTogglePause: () async -> Void
    let onCancelImport: () async -> Void
    let onDisconnect: () async -> Void

    var body: some View {
        Section {
            if state.isConnected {
                connectionRow
                fetchRow
                importRow
                disconnectButton
            } else if state.isCheckingStatus {
                HStack {
                    ProgressView()
                    Text("Chargement...")
                }
            } else {
                Button {
                    onConnect()
                } label: {
                    Label("Se connecter", systemImage: "")
                }
            }
        } header: {
            Label("Audible", systemImage: "headphones")
        }
    }

    // MARK: - Connection

    private var connectionRow: some View {
        Label("Connecté", systemImage: "checkmark.circle.fill")
            .foregroundStyle(.green)
    }

    // MARK: - Fetch

    @ViewBuilder
    private var fetchRow: some View {
        if state.isFetching {
            HStack(spacing: 8) {
                ProgressView()
                Text("Récupération des données...")
                    .foregroundStyle(.secondary)
            }
        } else if state.hasFetchedData {
            NavigationLink {
                AudibleEntriesPage()
            } label: {
                Label {
                    Text("\(state.libraryCount) livres · \(state.wishlistCount) liste d'envies")
                } icon: {
                    Image(systemName: "books.vertical")
                }
            }
            if let lastFetched = state.lastFetchedAt {
                LabeledInfoRow(
                    title: "Dernière mise à jour",
                    value: lastFetched.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year().hour().minute()),
                    icon: "clock"
                )
            }
            Button {
                Task { await onFetch() }
            } label: {
                Label("Actualiser les données", systemImage: "arrow.triangle.2.circlepath")
            }
        } else if !state.isImportActive {
            Button {
                Task { await onFetch() }
            } label: {
                Label("Récupérer les données Audible", systemImage: "arrow.triangle.2.circlepath")
            }
        }
    }

    // MARK: - Import

    @ViewBuilder
    private var importRow: some View {
        if state.isFetching {
            EmptyView()
        } else if let task = state.importTask,
            task.status == .running || task.status == .paused
        {
            importProgressRow(task)
            Button {
                Task { await onTogglePause() }
            } label: {
                if state.isPausing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text(task.status == .paused ? "Reprise..." : "Pause...")
                    }
                } else {
                    Label(
                        task.status == .paused ? "Reprendre l'import" : "Mettre en pause",
                        systemImage: task.status == .paused ? "play.fill" : "pause.fill"
                    )
                }
            }
            .disabled(state.isPausing || state.isCancelling)
            Button(role: .destructive) {
                Task { await onCancelImport() }
            } label: {
                if state.isCancelling {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Annulation...")
                    }
                } else {
                    Label("Annuler l'import", systemImage: "xmark.circle")
                }
            }
            .disabled(state.isPausing || state.isCancelling)
        } else if let task = state.importTask, task.status == .completed {
            Label("Import terminé", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            if state.importedCount > 0 {
                importSummaryRow
            }
        } else if state.hasFetchedData {
            if state.importedCount > 0 {
                importSummaryRow
            }
            Button {
                Task { await onImport() }
            } label: {
                if state.delta > 0 {
                    Label("Importer \(state.delta) livres", systemImage: "square.and.arrow.down")
                } else {
                    Label("Importer dans la bibliothèque", systemImage: "square.and.arrow.down")
                }
            }
        }
    }

    @ViewBuilder
    private func importProgressRow(_ task: ImportTaskState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.status == .paused ? "En pause" : task.message)
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

    private var importSummaryRow: some View {
        Label {
            if state.delta > 0 {
                Text("\(state.importedCount) importés · \(state.delta) restants")
            } else {
                Text("\(state.importedCount) livres importés")
            }
        } icon: {
            Image(systemName: "square.and.arrow.down")
        }
        .foregroundStyle(.secondary)
    }

    // MARK: - Disconnect

    @ViewBuilder
    private var disconnectButton: some View {
        if !state.isFetching, !state.isImportActive {
            Button(role: .destructive) {
                Task { await onDisconnect() }
            } label: {
                Label("Se déconnecter", systemImage: "person.slash")
            }
        }
    }
}

// MARK: - State

extension AudibleSection {
    struct State {
        let isConnected: Bool
        let isCheckingStatus: Bool
        let isFetching: Bool
        let hasFetchedData: Bool
        let libraryCount: Int
        let wishlistCount: Int
        let lastFetchedAt: Date?
        let importTask: ImportTaskState?
        let importedCount: Int
        let delta: Int
        let isImportActive: Bool
        let isPausing: Bool
        let isCancelling: Bool
    }
}

// MARK: - Previews

#Preview("Disconnected") {
    List {
        AudibleSection(
            state: .init(
                isConnected: false, isCheckingStatus: false,
                isFetching: false, hasFetchedData: false, libraryCount: 0,
                wishlistCount: 0, lastFetchedAt: nil, importTask: nil,
                importedCount: 0, delta: 0,
                isImportActive: false, isPausing: false, isCancelling: false
            ),
            onConnect: {}, onFetch: {}, onImport: {},
            onTogglePause: {}, onCancelImport: {}, onDisconnect: {}
        )
    }
}

#Preview("Checking status") {
    List {
        AudibleSection(
            state: .init(
                isConnected: false, isCheckingStatus: true,
                isFetching: false, hasFetchedData: false, libraryCount: 0,
                wishlistCount: 0, lastFetchedAt: nil, importTask: nil,
                importedCount: 0, delta: 0,
                isImportActive: false, isPausing: false, isCancelling: false
            ),
            onConnect: {}, onFetch: {}, onImport: {},
            onTogglePause: {}, onCancelImport: {}, onDisconnect: {}
        )
    }
}

#Preview("Connected with data") {
    List {
        AudibleSection(
            state: .init(
                isConnected: true, isCheckingStatus: false,
                isFetching: false, hasFetchedData: true, libraryCount: 142,
                wishlistCount: 8, lastFetchedAt: Date().addingTimeInterval(-3600),
                importTask: nil, importedCount: 0, delta: 142,
                isImportActive: false, isPausing: false, isCancelling: false
            ),
            onConnect: {}, onFetch: {}, onImport: {},
            onTogglePause: {}, onCancelImport: {}, onDisconnect: {}
        )
    }
}

#Preview("Connected with partial import") {
    List {
        AudibleSection(
            state: .init(
                isConnected: true, isCheckingStatus: false,
                isFetching: false, hasFetchedData: true, libraryCount: 142,
                wishlistCount: 8, lastFetchedAt: Date().addingTimeInterval(-3600),
                importTask: nil, importedCount: 138, delta: 4,
                isImportActive: false, isPausing: false, isCancelling: false
            ),
            onConnect: {}, onFetch: {}, onImport: {},
            onTogglePause: {}, onCancelImport: {}, onDisconnect: {}
        )
    }
}

#Preview("Importing") {
    List {
        AudibleSection(
            state: .init(
                isConnected: true, isCheckingStatus: false,
                isFetching: false, hasFetchedData: true, libraryCount: 142,
                wishlistCount: 8, lastFetchedAt: Date().addingTimeInterval(-3600),
                importTask: ImportTaskState(
                    status: .running, current: 45, total: 142,
                    message: "Import en cours...", startedAt: Date()
                ),
                importedCount: 45, delta: 97,
                isImportActive: true, isPausing: false, isCancelling: false
            ),
            onConnect: {}, onFetch: {}, onImport: {},
            onTogglePause: {}, onCancelImport: {}, onDisconnect: {}
        )
    }
}

#Preview("Import complete") {
    List {
        AudibleSection(
            state: .init(
                isConnected: true, isCheckingStatus: false,
                isFetching: false, hasFetchedData: true, libraryCount: 142,
                wishlistCount: 8, lastFetchedAt: Date().addingTimeInterval(-3600),
                importTask: ImportTaskState(
                    status: .completed, current: 142, total: 142,
                    message: "Import terminé", completedAt: Date()
                ),
                importedCount: 142, delta: 0,
                isImportActive: false, isPausing: false, isCancelling: false
            ),
            onConnect: {}, onFetch: {}, onImport: {},
            onTogglePause: {}, onCancelImport: {}, onDisconnect: {}
        )
    }
}
