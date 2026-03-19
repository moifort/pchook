import Foundation

@MainActor @Observable
final class AudibleViewModel {
    private(set) var isConnected = false
    private(set) var isVerifying = false
    private(set) var isFetching = false
    private(set) var isImporting = false
    private(set) var isCheckingStatus = false
    private(set) var summaryResult: AudibleSummary?
    private(set) var importResult: ImportResult?
    private(set) var libraryCount = 0
    private(set) var wishlistCount = 0
    private(set) var lastSyncAt: Date?
    private(set) var syncProgress: SyncProgressData?
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

            if isConnected, shouldVerify {
                await verify()
            }

            if !isBusy {
                let progress = try await AudibleAPI.syncProgress()
                if progress.phase != "idle" {
                    syncProgress = progress
                    resumePolling(for: progress.phase)
                }
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
        summaryResult = nil

        pollingTask = Task { await pollProgress() }

        do {
            summaryResult = try await AudibleAPI.syncFetch()
            await refreshStatus()
        } catch {
            self.error = reportError(error)
        }

        isFetching = false
        syncProgress = nil
        pollingTask?.cancel()
        pollingTask = nil
    }

    // MARK: - Step 3: Import (user action)

    func importBooks() async {
        isImporting = true
        error = nil
        syncProgress = nil
        importResult = nil

        pollingTask = Task { await pollProgress() }

        do {
            importResult = try await AudibleAPI.syncImport()
            await refreshStatus()
        } catch {
            self.error = reportError(error)
        }

        isImporting = false
        syncProgress = nil
        pollingTask?.cancel()
        pollingTask = nil
    }

    // MARK: - Polling

    private func pollProgress() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { break }
            do {
                syncProgress = try await AudibleAPI.syncProgress()
            } catch {
                break
            }
        }
    }

    private func resumePolling(for phase: String) {
        if phase == "downloading" {
            isFetching = true
        } else if phase == "importing" {
            isImporting = true
        }
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { break }
                do {
                    let progress = try await AudibleAPI.syncProgress()
                    syncProgress = progress
                    if progress.phase == "idle" || progress.phase == "done" {
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
            summaryResult = nil
            importResult = nil
            lastVerifiedAt = nil
        } catch {
            self.error = reportError(error)
        }
    }

    func cancelPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        isFetching = false
        isImporting = false
        syncProgress = nil
    }

    // MARK: - Private

    private func refreshStatus() async {
        do {
            let status = try await AudibleAPI.status()
            libraryCount = status.libraryCount
            wishlistCount = status.wishlistCount
            lastSyncAt = status.lastSyncAt
        } catch {}
    }
}
