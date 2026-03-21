import Foundation

@MainActor @Observable
final class AudibleViewModel {
    private(set) var isConnected = false
    private(set) var isVerifying = false
    private(set) var isFetching = false
    private(set) var isImporting = false
    private(set) var isCheckingStatus = false
    private(set) var hasFetchedData = false
    private(set) var libraryCount = 0
    private(set) var wishlistCount = 0
    private(set) var lastSyncAt: Date?
    private(set) var syncProgress: SyncProgressData?
    private(set) var isPaused = false
    var error: String?
    var showLogin = false

    private var lastVerifiedAt: Date?
    private var pollingTask: Task<Void, Never>?

    var isBusy: Bool { isFetching || isImporting }

    // MARK: - Auto verify on page open (cached 1h)

    func checkStatusAndVerify() async {
        isCheckingStatus = true
        defer { isCheckingStatus = false }

        do {
            let status = try await AudibleAPI.status()
            isConnected = status.connected
            libraryCount = status.libraryCount
            wishlistCount = status.wishlistCount
            lastSyncAt = status.lastSyncAt

            let progress = try await AudibleAPI.syncProgress()

            if isConnected, shouldVerify, progress.phase == "idle" {
                await verify()
            }
            if progress.phase != "idle" {
                syncProgress = progress
                if pollingTask == nil {
                    resumePolling(for: progress.phase)
                }
            } else if isBusy {
                isFetching = false
                isImporting = false
                syncProgress = nil
                await refreshStatus()
            }

            if status.rawItemCount > 0 {
                hasFetchedData = true
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

    // MARK: - Step 2: Fetch (user action)

    func fetch() async {
        isFetching = true
        error = nil
        syncProgress = nil
        hasFetchedData = false

        do {
            try await AudibleAPI.syncFetch()
            resumePolling(for: "downloading")
        } catch {
            isFetching = false
            self.error = reportError(error)
        }
    }

    // MARK: - Step 3: Import (user action)

    func importBooks() async {
        isImporting = true
        error = nil
        syncProgress = nil

        do {
            try await AudibleAPI.syncImport()
            resumePolling(for: "importing")
        } catch {
            isImporting = false
            self.error = reportError(error)
        }
    }

    // MARK: - Sync control

    func togglePause() async {
        do {
            let paused = try await AudibleAPI.syncPause()
            isPaused = paused
        } catch {
            self.error = reportError(error)
        }
    }

    func cancelSync() async {
        do {
            try await AudibleAPI.syncCancel()
            isPaused = false
            isFetching = false
            isImporting = false
            syncProgress = nil
            cancelPolling()
            await refreshStatus()
        } catch {
            self.error = reportError(error)
        }
    }

    // MARK: - Polling

    private func resumePolling(for phase: String) {
        if phase == "downloading" {
            isFetching = true
        } else if phase == "importing" {
            isImporting = true
        }
        pollingTask = Task {
            var isFirstPoll = true
            while !Task.isCancelled {
                if isFirstPoll {
                    isFirstPoll = false
                } else {
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { break }
                }
                do {
                    let progress = try await AudibleAPI.syncProgress()
                    syncProgress = progress
                    if progress.phase == "paused" {
                        isPaused = true
                    }
                    if progress.phase == "idle" || progress.phase == "done" {
                        isPaused = false
                        if isFetching { hasFetchedData = true }
                        isFetching = false
                        isImporting = false
                        syncProgress = nil
                        await refreshStatus()
                        return
                    }
                } catch {
                    break
                }
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
            lastSyncAt = nil
            hasFetchedData = false
            lastVerifiedAt = nil
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
            lastSyncAt = status.lastSyncAt
            if status.rawItemCount > 0 { hasFetchedData = true }
        } catch {}
    }
}
