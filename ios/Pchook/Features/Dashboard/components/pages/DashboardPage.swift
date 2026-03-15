import Sentry
import SentrySwiftUI
import SwiftUI

struct DashboardPage: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let data = viewModel.data {
                    ScrollView {
                        VStack(spacing: 20) {
                            StatsSection(
                                total: data.bookCount.total,
                                toRead: data.bookCount.toRead,
                                read: data.bookCount.read
                            )

                            FavoriteBooksSectionView(
                                items: data.favorites.map { favorite in
                                    .init(
                                        id: favorite.id,
                                        title: favorite.title,
                                        authors: favorite.authors.joined(separator: ", "),
                                        genre: favorite.genre,
                                        rating: favorite.rating,
                                        estimatedPrice: favorite.estimatedPrice
                                    )
                                }
                            )

                            RecentBooksSection(
                                items: data.recentBooks.map { book in
                                    .init(
                                        id: book.id,
                                        title: book.title,
                                        authors: book.authors.joined(separator: ", "),
                                        genre: book.genre,
                                        createdAt: book.createdAt
                                    )
                                }
                            )

                            RecentAwardsSection(
                                items: data.recentAwards.map { award in
                                    .init(
                                        bookTitle: award.bookTitle,
                                        authors: award.authors.joined(separator: ", "),
                                        awardName: award.awardName,
                                        awardYear: award.awardYear
                                    )
                                }
                            )
                        }
                        .padding()
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
            .task {
                await viewModel.load()
                SentrySDK.reportFullyDisplayed()
            }
        }
    }
}

#Preview {
    DashboardPage()
}
