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

    var hasFetchedData: Bool { libraryCount > 0 || wishlistCount > 0 }
    var isImportActive: Bool {
        guard let task = importTask else { return false }
        return task.status == .running || task.status == .paused
    }

    // MARK: - Load status on page open

    func checkStatusAndVerify() async {
        isCheckingStatus = true
        defer { isCheckingStatus = false }
        do {
            let data = try await GraphQLAudibleAPI.status()
            applyStatus(data)

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
            let data = try await GraphQLAudibleAPI.status()
            applyStatus(data)
            startImportPolling()
        } catch {
            self.error = reportError(error)
        }
    }

    func toggleImportPause() async {
        isPausing = true
        do {
            if importTask?.status == .paused {
                try await GraphQLAudibleAPI.importResume()
            } else {
                try await GraphQLAudibleAPI.importPause()
            }
        } catch {
            isPausing = false
            self.error = reportError(error)
        }
    }

    func cancelImport() async {
        isCancelling = true
        do {
            try await GraphQLAudibleAPI.importCancel()
        } catch {
            isCancelling = false
            self.error = reportError(error)
        }
    }

    private func startImportPolling() {
        cancelPolling()
        pollingTask = Task {
            while !Task.isCancelled {
                do {
                    let data = try await GraphQLAudibleAPI.status()
                    applyStatus(data)
                    if let task = importTask {
                        if task.status == .paused { isPausing = false }
                        if task.status.isTerminal {
                            isPausing = false
                            isCancelling = false
                            return
                        }
                    }
                } catch {
                    break
                }
                try? await Task.sleep(for: .seconds(2))
            }
        }
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

        importedCount = data.import_.importedCount
        delta = data.import_.delta

        let imp = data.import_
        if imp.status == .idle, imp.current == 0 {
            importTask = nil
        } else {
            importTask = ImportTaskState(
                status: imp.status,
                current: imp.current,
                total: imp.total,
                message: imp.message,
                startedAt: imp.startedAt,
                completedAt: imp.completedAt
            )
        }
    }

    private func refreshStatus() async {
        do {
            let data = try await GraphQLAudibleAPI.status()
            applyStatus(data)
        } catch {}
    }
}
