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
            if state.isConnected || state.isVerifying {
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
                    Label("Se connecter \u{00E0} Audible", systemImage: "headphones")
                }
            }
        } header: {
            Label("Audible", systemImage: "headphones")
        }
    }

    // MARK: - Connection

    @ViewBuilder
    private var connectionRow: some View {
        if state.isVerifying {
            HStack(spacing: 8) {
                ProgressView()
                Text("V\u{00E9}rification de la connexion...")
                    .foregroundStyle(.secondary)
            }
        } else {
            Label("Connect\u{00E9}", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
    }

    // MARK: - Fetch

    @ViewBuilder
    private var fetchRow: some View {
        if state.isVerifying {
            EmptyView()
        } else if state.isFetching {
            HStack(spacing: 8) {
                ProgressView()
                Text("R\u{00E9}cup\u{00E9}ration des donn\u{00E9}es...")
                    .foregroundStyle(.secondary)
            }
        } else if state.hasFetchedData {
            Label {
                Text("\(state.libraryCount) livres \u{00B7} \(state.wishlistCount) souhaits")
            } icon: {
                Image(systemName: "books.vertical")
            }
            if let lastFetched = state.lastFetchedAt {
                HStack {
                    Label("Derni\u{00E8}re mise \u{00E0} jour", systemImage: "clock")
                    Spacer()
                    Text(lastFetched, style: .relative)
                        .foregroundStyle(.secondary)
                }
            }
            Button {
                Task { await onFetch() }
            } label: {
                Label("Actualiser les donn\u{00E9}es", systemImage: "arrow.triangle.2.circlepath")
            }
        } else if !state.isImportActive {
            Button {
                Task { await onFetch() }
            } label: {
                Label("R\u{00E9}cup\u{00E9}rer les donn\u{00E9}es Audible", systemImage: "arrow.triangle.2.circlepath")
            }
        }
    }

    // MARK: - Import

    @ViewBuilder
    private var importRow: some View {
        if state.isVerifying || state.isFetching {
            EmptyView()
        } else if let task = state.importTask,
            task.phase == .running || task.phase == .paused
        {
            importProgressRow(task)
            Button {
                Task { await onTogglePause() }
            } label: {
                if state.isPausing {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text(task.phase == .paused ? "Reprise..." : "Pause...")
                    }
                } else {
                    Label(
                        task.phase == .paused ? "Reprendre l'import" : "Mettre en pause",
                        systemImage: task.phase == .paused ? "play.fill" : "pause.fill"
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
        } else if let task = state.importTask, task.phase == .completed {
            Label("Import termin\u{00E9}", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        } else if state.hasFetchedData {
            Button {
                Task { await onImport() }
            } label: {
                Label("Importer dans la biblioth\u{00E8}que", systemImage: "square.and.arrow.down")
            }
        }
    }

    @ViewBuilder
    private func importProgressRow(_ task: ImportTaskState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(task.phase == .paused ? "En pause" : task.message)
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
        if !state.isVerifying, !state.isFetching, !state.isImportActive {
            Button(role: .destructive) {
                Task { await onDisconnect() }
            } label: {
                Label("Se d\u{00E9}connecter", systemImage: "person.slash")
            }
        }
    }
}

// MARK: - State

extension AudibleSection {
    struct State {
        let isConnected: Bool
        let isCheckingStatus: Bool
        let isVerifying: Bool
        let isFetching: Bool
        let hasFetchedData: Bool
        let libraryCount: Int
        let wishlistCount: Int
        let lastFetchedAt: Date?
        let importTask: ImportTaskState?
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
                isConnected: false, isCheckingStatus: false, isVerifying: false,
                isFetching: false, hasFetchedData: false, libraryCount: 0,
                wishlistCount: 0, lastFetchedAt: nil, importTask: nil,
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
                isConnected: false, isCheckingStatus: true, isVerifying: false,
                isFetching: false, hasFetchedData: false, libraryCount: 0,
                wishlistCount: 0, lastFetchedAt: nil, importTask: nil,
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
                isConnected: true, isCheckingStatus: false, isVerifying: false,
                isFetching: false, hasFetchedData: true, libraryCount: 142,
                wishlistCount: 8, lastFetchedAt: Date().addingTimeInterval(-3600),
                importTask: nil, isImportActive: false, isPausing: false, isCancelling: false
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
                isConnected: true, isCheckingStatus: false, isVerifying: false,
                isFetching: false, hasFetchedData: true, libraryCount: 142,
                wishlistCount: 8, lastFetchedAt: Date().addingTimeInterval(-3600),
                importTask: ImportTaskState(
                    phase: .running, current: 45, total: 142,
                    message: "Import en cours...", startedAt: Date()
                ),
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
                isConnected: true, isCheckingStatus: false, isVerifying: false,
                isFetching: false, hasFetchedData: true, libraryCount: 142,
                wishlistCount: 8, lastFetchedAt: Date().addingTimeInterval(-3600),
                importTask: ImportTaskState(
                    phase: .completed, current: 142, total: 142,
                    message: "Import termin\u{00E9}", completedAt: Date()
                ),
                isImportActive: false, isPausing: false, isCancelling: false
            ),
            onConnect: {}, onFetch: {}, onImport: {},
            onTogglePause: {}, onCancelImport: {}, onDisconnect: {}
        )
    }
}
