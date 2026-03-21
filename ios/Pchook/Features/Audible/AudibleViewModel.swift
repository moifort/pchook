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
    private(set) var rawItemCount = 0

    // Section 3: Import
    private(set) var importTask: ImportTaskState?
    private(set) var isPausing = false
    private(set) var isCancelling = false

    var error: String?
    var showLogin = false

    private var lastVerifiedAt: Date?
    private var pollingTask: Task<Void, Never>?

    var hasFetchedData: Bool { rawItemCount > 0 }
    var isImportActive: Bool {
        guard let task = importTask else { return false }
        return task.phase == "running" || task.phase == "paused"
    }

    // MARK: - Load status on page open

    func checkStatusAndVerify() async {
        isCheckingStatus = true
        defer { isCheckingStatus = false }

        do {
            let status = try await AudibleAPI.status()
            isConnected = status.connected
            isFetching = status.fetchInProgress
            libraryCount = status.libraryCount
            wishlistCount = status.wishlistCount
            lastFetchedAt = status.lastFetchedAt
            rawItemCount = status.rawItemCount
            importTask = status.importTask

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

    // MARK: - Step 1: Verify

    func verify() async {
        isVerifying = true
        defer { isVerifying = false }
        do {
            try await AudibleAPI.syncVerify()
            lastVerifiedAt = Date()
        } catch {
            self.error = reportError(error)
            isConnected = false
        }
    }

    // MARK: - Step 2: Fetch

    func fetch() async {
        isFetching = true
        error = nil

        do {
            try await AudibleAPI.syncFetch()
            startFetchPolling()
        } catch {
            isFetching = false
            self.error = reportError(error)
        }
    }

    private func startFetchPolling() {
        cancelPolling()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { break }
                do {
                    let status = try await AudibleAPI.status()
                    isFetching = status.fetchInProgress
                    libraryCount = status.libraryCount
                    wishlistCount = status.wishlistCount
                    lastFetchedAt = status.lastFetchedAt
                    rawItemCount = status.rawItemCount
                    if !status.fetchInProgress {
                        return
                    }
                } catch {
                    break
                }
            }
        }
    }

    // MARK: - Step 3: Import

    func startImport() async {
        error = nil
        do {
            try await AudibleAPI.importStart()
            startImportPolling()
        } catch {
            self.error = reportError(error)
        }
    }

    func toggleImportPause() async {
        isPausing = true
        do {
            _ = try await AudibleAPI.importPause()
        } catch {
            isPausing = false
            self.error = reportError(error)
        }
    }

    func cancelImport() async {
        isCancelling = true
        do {
            try await AudibleAPI.importCancel()
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
                    let state = try await AudibleAPI.importState()
                    importTask = state
                    if state.phase == "paused" { isPausing = false }
                    if state.phase == "idle" || state.phase == "completed"
                        || state.phase == "cancelled" || state.phase == "failed"
                    {
                        isPausing = false
                        isCancelling = false
                        await refreshStatus()
                        return
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
            try await AudibleAPI.disconnect()
            isConnected = false
            libraryCount = 0
            wishlistCount = 0
            lastFetchedAt = nil
            rawItemCount = 0
            importTask = nil
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

    private func refreshStatus() async {
        do {
            let status = try await AudibleAPI.status()
            libraryCount = status.libraryCount
            wishlistCount = status.wishlistCount
            lastFetchedAt = status.lastFetchedAt
            rawItemCount = status.rawItemCount
            importTask = status.importTask
        } catch {}
    }
}
