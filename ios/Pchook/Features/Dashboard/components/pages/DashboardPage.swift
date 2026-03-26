import Sentry
import SentrySwiftUI
import SwiftUI

struct DashboardPage: View {
    @Binding var refreshTrigger: Int

    @State private var viewModel = DashboardViewModel()
    @State private var showSync = false
    @State private var selectedBookId: String?

    var body: some View {
        NavigationStack {
            Group {
                if let data = viewModel.data {
                    List {
                        StatsSection(
                            total: data.bookCount.total,
                            toRead: data.bookCount.toRead,
                            read: data.bookCount.read,
                            totalAudioMinutes: data.bookCount.totalAudioMinutes
                        )

                        FavoriteSeriesSection(
                            items: data.favoriteSeries,
                            onSelect: { selectedBookId = $0 }
                        )

                        FavoriteBooksSectionView(
                            items: data.favorites,
                            onSelect: { selectedBookId = $0 }
                        )

                        RecentBooksSection(
                            items: data.recentBooks,
                            onSelect: { selectedBookId = $0 }
                        )

                        RecommendedBooksSection(
                            items: data.recommendedBooks,
                            onSelect: { selectedBookId = $0 }
                        )
                    }
                } else if let error = viewModel.error {
                    ContentUnavailableView("Erreur", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    ProgressView("Chargement...")
                }
            }
            .navigationTitle("Accueil")
            .navigationBarTitleDisplayMode(.large)
            .sentryTrace("Dashboard", waitForFullDisplay: true)
            .refreshable { await viewModel.load() }
            .task(id: refreshTrigger) {
                await viewModel.load()
                SentrySDK.reportFullyDisplayed()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSync = true
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
            .sheet(isPresented: $showSync, onDismiss: {
                refreshTrigger += 1
            }) {
                SyncPage(refreshTrigger: refreshTrigger)
            }
            .sheet(
                item: Binding(
                    get: { selectedBookId.map { BookIdWrapper(id: $0) } },
                    set: { selectedBookId = $0?.id }
                ),
                onDismiss: { Task { await viewModel.load() } }
            ) { wrapper in
                BookDetailCoordinator(bookId: wrapper.id)
            }
        }
    }
}

#Preview {
    DashboardPage(refreshTrigger: .constant(0))
}
