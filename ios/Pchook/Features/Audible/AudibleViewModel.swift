import Apollo
import Foundation

@MainActor @Observable
final class AudibleViewModel {
    // Section 1: Connection
    private(set) var isConnected = false
    private(set) var isCheckingStatus = false
    private(set) var isVerifying = false

    // Section 2: Fetch
    private(set) var isFetching = false
    private(set) var libraryCount = 0
    private(set) var wishlistCount = 0
    private(set) var lastFetchedAt: Date?

    // Section 3: Import
    private(set) var importTask: ImportTaskState?
    private(set) var importedCount = 0
    private(set) var delta = 0
    private(set) var isPausing = false
    private(set) var isCancelling = false

    var error: String?
    var showLogin = false

    private var lastVerifiedAt: Date?
    private var pollingTask: Task<Void, Never>?
    private var importTaskId: String?

    var hasFetchedData: Bool { libraryCount > 0 || wishlistCount > 0 }
    var isImportActive: Bool {
        guard let task = importTask else { return false }
        return task.phase == .running || task.phase == .paused
    }

    // MARK: - Load status on page open

    func checkStatusAndVerify() async {
        isCheckingStatus = true
        defer { isCheckingStatus = false }
        do {
            let data = try await GraphQLAudibleAPI.status()
            applyStatus(data)

            if let taskId = importTaskId {
                await refreshImportTask(taskId: taskId)
            }

            if isConnected, shouldVerify, !isFetching, !isImportActive {
                await verify()
            }

            if isFetching {
                startFetchPolling()
            }

            if isImportActive {
                startImportPolling()
            }
        } catch {
            self.error = reportError(error)
        }
    }

    private var shouldVerify: Bool {
        guard let lastVerifiedAt else { return true }
        return Date().timeIntervalSince(lastVerifiedAt) > 3600
    }

    // MARK: - Verify

    private func verify() async {
        isVerifying = true
        defer { isVerifying = false }
        do {
            try await GraphQLAudibleAPI.syncVerify()
            lastVerifiedAt = Date()
        } catch {
            // Silently ignore verification errors
        }
    }

    // MARK: - Fetch

    func fetchLibrary() async {
        do {
            try await GraphQLAudibleAPI.syncFetch()
            isFetching = true
            startFetchPolling()
        } catch {
            self.error = reportError(error)
        }
    }

    private func startFetchPolling() {
        cancelPolling()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                do {
                    let data = try await GraphQLAudibleAPI.status()
                    applyStatus(data)
                    if !isFetching { return }
                } catch {
                    break
                }
            }
        }
    }

    // MARK: - Import

    func startImport() async {
        do {
            try await GraphQLAudibleAPI.importStart()
            // Refresh to get the new taskId
            let data = try await GraphQLAudibleAPI.status()
            applyStatus(data)
            if let taskId = importTaskId {
                await refreshImportTask(taskId: taskId)
            }
            startImportPolling()
        } catch {
            self.error = reportError(error)
        }
    }

    func toggleImportPause() async {
        guard let taskId = importTaskId else { return }
        isPausing = true
        do {
            let client = GraphQLClient.shared.apollo
            if importTask?.phase == .paused {
                _ = try await GraphQLHelpers.perform(client, mutation: PchookGraphQL.ResumeTaskMutation(id: taskId))
            } else {
                _ = try await GraphQLHelpers.perform(client, mutation: PchookGraphQL.PauseTaskMutation(id: taskId))
            }
        } catch {
            isPausing = false
            self.error = reportError(error)
        }
    }

    func cancelImport() async {
        guard let taskId = importTaskId else { return }
        isCancelling = true
        do {
            let client = GraphQLClient.shared.apollo
            _ = try await GraphQLHelpers.perform(client, mutation: PchookGraphQL.CancelTaskMutation(id: taskId))
        } catch {
            isCancelling = false
            self.error = reportError(error)
        }
    }

    private func startImportPolling() {
        cancelPolling()
        guard let taskId = importTaskId else { return }
        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    await refreshImportTask(taskId: taskId)
                    if let task = importTask {
                        if task.phase == .paused { isPausing = false }
                        if task.phase.isTerminal {
                            isPausing = false
                            isCancelling = false
                            await refreshStatus()
                            return
                        }
                    }
                }
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    private func refreshImportTask(taskId: String) async {
        let client = GraphQLClient.shared.apollo
        do {
            let query = PchookGraphQL.TaskByIdQuery(id: taskId)
            let data = try await GraphQLHelpers.fetch(client, query: query)
            if let task = data.task {
                importTask = ImportTaskState(
                    phase: TaskPhase(rawValue: task.phase) ?? .idle,
                    current: task.current,
                    total: task.total,
                    message: task.message,
                    startedAt: task.startedAt.flatMap(GraphQLHelpers.parseISO8601),
                    completedAt: task.completedAt.flatMap(GraphQLHelpers.parseISO8601)
                )
            }
        } catch {}
    }

    // MARK: - Auth

    func onLoginComplete() async {
        showLogin = false
        lastVerifiedAt = nil
        await checkStatusAndVerify()
    }

    func disconnect() async {
        do {
            try await GraphQLAudibleAPI.disconnect()
            isConnected = false
            isFetching = false
            libraryCount = 0
            wishlistCount = 0
            lastFetchedAt = nil
            importTask = nil
            importTaskId = nil
            importedCount = 0
            delta = 0
            lastVerifiedAt = nil
            cancelPolling()
        } catch {
            self.error = reportError(error)
        }
    }

    func cancelPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    // MARK: - Private

    private func applyStatus(_ data: AudibleData) {
        isConnected = data.sync.status != .disconnected
        isFetching = data.sync.status == .fetching
        libraryCount = data.sync.libraryCount
        wishlistCount = data.sync.wishlistCount
        lastFetchedAt = data.sync.updatedAt

        importTaskId = data.import_.taskId
        importedCount = data.import_.importedCount
        delta = data.import_.delta
    }

    private func refreshStatus() async {
        do {
            let data = try await GraphQLAudibleAPI.status()
            applyStatus(data)
        } catch {}
    }
}
