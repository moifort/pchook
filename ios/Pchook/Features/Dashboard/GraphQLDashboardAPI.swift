import Apollo
import Foundation

enum GraphQLDashboardAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func getData() async throws -> DashboardData {
        let query = PchookGraphQL.DashboardQuery()
        let data = try await GraphQLHelpers.fetch(client, query: query)

        let dashboard = data.dashboard
        return DashboardData(
            bookCount: BookCount(
                total: dashboard.bookCount.total,
                toRead: dashboard.bookCount.toRead,
                read: dashboard.bookCount.read,
                totalAudioMinutes: dashboard.bookCount.totalAudioMinutes
            ),
            favorites: dashboard.favorites.map { fav in
                DashboardBook(
                    id: fav.id,
                    title: fav.title,
                    authors: fav.authors,
                    genre: fav.genre,
                    language: fav.language?.rawValue
                )
            },
            recentBooks: dashboard.recentBooks.map { book in
                DashboardBook(
                    id: book.id,
                    title: book.title,
                    authors: book.authors,
                    genre: book.genre,
                    language: book.language?.rawValue
                )
            },
            recommendedBooks: dashboard.recommendedBooks.map { book in
                DashboardBook(
                    id: book.id,
                    title: book.title,
                    authors: book.authors,
                    genre: book.genre,
                    language: book.language?.rawValue,
                    recommendedBy: book.recommendedBy
                )
            },
            favoriteSeries: dashboard.favoriteSeries.map { series in
                DashboardSeries(
                    id: series.id,
                    name: series.name,
                    volumeCount: series.volumeCount,
                    authors: series.authors,
                    language: series.language?.rawValue,
                    firstBookId: series.firstBookId
                )
            }
        )
    }
}
