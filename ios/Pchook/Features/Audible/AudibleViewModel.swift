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
    var error: String?
    var showLogin = false

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

    func startSync() async {
        isSyncing = true
        error = nil
        defer { isSyncing = false }
        do {
            lastSyncResult = try await AudibleAPI.sync()
            await checkStatus()
        } catch {
            self.error = reportError(error)
        }
    }

    func onLoginComplete() async {
        showLogin = false
        await checkStatus()
    }
}
