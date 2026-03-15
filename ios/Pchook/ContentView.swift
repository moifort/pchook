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
    @State private var selectedTab: TabSelection = .home
    @State private var showScanner = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(TabSelection.home.label, systemImage: TabSelection.home.icon, value: .home) {
                DashboardPage()
            }
            .accessibilityIdentifier("tab-home")
            Tab(TabSelection.books.label, systemImage: TabSelection.books.icon, value: .books) {
                BooksPage()
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
        .fullScreenCover(isPresented: $showScanner) {
            ScanFlowView {
                showScanner = false
                selectedTab = .books
            }
        }
    }
}

#Preview {
    ContentView()
}
