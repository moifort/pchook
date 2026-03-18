import SwiftUI

struct SyncPage: View {
    let refreshTrigger: Int
    @State private var audibleViewModel = AudibleViewModel()

    var body: some View {
        NavigationStack {
            List {
                AudibleSection(viewModel: audibleViewModel)
            }
            .navigationTitle("Synchronisation")
            .task(id: refreshTrigger) { await audibleViewModel.checkStatus() }
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
