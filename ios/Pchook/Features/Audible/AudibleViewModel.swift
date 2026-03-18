import Foundation

@MainActor @Observable
final class AudibleViewModel {
    private(set) var isConnected = false
    private(set) var isSyncing = false
    private(set) var isCheckingStatus = false
    private(set) var lastSyncResult: SyncResult?
    private(set) var libraryCount = 0
    private(set) var wishlistCount = 0
    private(set) var lastSyncAt: Date?
    private(set) var syncProgress: SyncProgressData?
    var error: String?
    var showLogin = false
    var showSyncConfirmation = false

    func checkStatus() async {
        isCheckingStatus = true
        defer { isCheckingStatus = false }
        do {
            let status = try await AudibleAPI.status()
            isConnected = status.connected
            libraryCount = status.libraryCount
            wishlistCount = status.wishlistCount
            lastSyncAt = status.lastSyncAt
        } catch {
            self.error = reportError(error)
        }
    }

    func requestSync() {
        showSyncConfirmation = true
    }

    func confirmSync() async {
        isSyncing = true
        error = nil
        syncProgress = nil

        async let syncTask: Void = performSync()
        async let pollingTask: Void = pollProgress()

        _ = await (syncTask, pollingTask)
    }

    private func performSync() async {
        defer {
            isSyncing = false
            syncProgress = nil
        }
        do {
            lastSyncResult = try await AudibleAPI.sync()
            await checkStatus()
        } catch {
            self.error = reportError(error)
        }
    }

    private func pollProgress() async {
        while isSyncing {
            try? await Task.sleep(for: .seconds(2))
            guard isSyncing else { break }
            do {
                syncProgress = try await AudibleAPI.syncProgress()
            } catch {
                break
            }
        }
    }

    func onLoginComplete() async {
        showLogin = false
        await checkStatus()
    }

    func disconnect() async {
        do {
            try await AudibleAPI.disconnect()
            isConnected = false
            libraryCount = 0
            wishlistCount = 0
            lastSyncAt = nil
            lastSyncResult = nil
        } catch {
            self.error = reportError(error)
        }
    }
}
