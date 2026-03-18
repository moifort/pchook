import SwiftUI

enum TabSelection: Int, CaseIterable, Identifiable {
    case home, books, scan
    var id: Int { rawValue }
    var label: String {
        switch self {
        case .home: "Accueil"
        case .books: "Livres"
        case .scan: "Scanner"
        }
    }
    var icon: String {
        switch self {
        case .home: "house"
        case .books: "books.vertical"
        case .scan: "camera"
        }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: TabSelection = .home
    @State private var showScanner = false
    @State private var refreshTrigger = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(TabSelection.home.label, systemImage: TabSelection.home.icon, value: .home) {
                DashboardPage(refreshTrigger: $refreshTrigger)
            }
            .accessibilityIdentifier("tab-home")
            Tab(TabSelection.books.label, systemImage: TabSelection.books.icon, value: .books) {
                BooksPage(refreshTrigger: refreshTrigger)
            }
            .accessibilityIdentifier("tab-books")
            Tab(value: .scan, role: .search) {
                Color.clear
            } label: {
                Label(TabSelection.scan.label, systemImage: TabSelection.scan.icon)
            }
            .accessibilityIdentifier("tab-scan")
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .scan {
                selectedTab = oldValue
                showScanner = true
            }
        }
        .fullScreenCover(isPresented: $showScanner, onDismiss: { refreshTrigger += 1 }) {
            ScanFlowView {
                showScanner = false
                selectedTab = .books
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshTrigger += 1
            }
        }
    }
}

#Preview {
    ContentView()
}
