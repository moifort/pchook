import SwiftUI

struct SyncPage: View {
    let refreshTrigger: Int
    @Environment(\.dismiss) private var dismiss
    @State private var audibleViewModel = AudibleViewModel()

    var body: some View {
        NavigationStack {
            List {
                AudibleSection(viewModel: audibleViewModel)
            }
            .navigationTitle("Synchronisation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer", systemImage: "xmark") { dismiss() }
                }
            }
            .task(id: refreshTrigger) { await audibleViewModel.checkStatusAndVerify() }
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
