import SwiftUI

struct SyncPage: View {
    let refreshTrigger: Int
    @Environment(\.dismiss) private var dismiss
    @State private var audibleViewModel = AudibleViewModel()

    var body: some View {
        NavigationStack {
            List {
                AudibleSection(
                    state: .init(
                        isConnected: audibleViewModel.isConnected,
                        isCheckingStatus: audibleViewModel.isCheckingStatus,
                        isFetching: audibleViewModel.isFetching,
                        hasFetchedData: audibleViewModel.hasFetchedData,
                        libraryCount: audibleViewModel.libraryCount,
                        wishlistCount: audibleViewModel.wishlistCount,
                        lastFetchedAt: audibleViewModel.lastFetchedAt,
                        importTask: audibleViewModel.importTask,
                        importedCount: audibleViewModel.importedCount,
                        delta: audibleViewModel.delta,
                        isImportActive: audibleViewModel.isImportActive,
                        isPausing: audibleViewModel.isPausing,
                        isCancelling: audibleViewModel.isCancelling
                    ),
                    onConnect: { audibleViewModel.showLogin = true },
                    onFetch: { await audibleViewModel.fetchLibrary() },
                    onImport: { await audibleViewModel.startImport() },
                    onTogglePause: { await audibleViewModel.toggleImportPause() },
                    onCancelImport: { await audibleViewModel.cancelImport() },
                    onDisconnect: { await audibleViewModel.disconnect() }
                )
            }
            .navigationTitle("Synchronisation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer", systemImage: "xmark") { dismiss() }
                }
            }
            .task(id: refreshTrigger) { await audibleViewModel.checkStatus() }
            .onDisappear { audibleViewModel.cancelPolling() }
            .sheet(isPresented: $audibleViewModel.showLogin) {
                AudibleLoginSheet {
                    await audibleViewModel.onLoginComplete()
                }
            }
            .alert("Erreur", isPresented: .constant(audibleViewModel.error != nil)) {
                Button("OK") { audibleViewModel.error = nil }
            } message: {
                if let error = audibleViewModel.error {
                    Text(error)
                }
            }
        }
    }
}

#Preview {
    SyncPage(refreshTrigger: 0)
}
