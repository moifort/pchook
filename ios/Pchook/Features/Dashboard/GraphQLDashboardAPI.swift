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
                read: dashboard.bookCount.read
            ),
            favorites: dashboard.favorites.map { fav in
                FavoriteBook(
                    id: fav.id,
                    title: fav.title,
                    authors: fav.authors,
                    genre: fav.genre,
                    rating: fav.rating,
                    estimatedPrice: fav.estimatedPrice
                )
            },
            recentBooks: dashboard.recentBooks.map { book in
                RecentBook(
                    id: book.id,
                    title: book.title,
                    authors: book.authors,
                    genre: book.genre,
                    createdAt: GraphQLHelpers.parseISO8601(book.createdAt) ?? Date()
                )
            },
            recentAwards: dashboard.recentAwards.map { award in
                RecentAward(
                    bookTitle: award.bookTitle,
                    authors: award.authors,
                    awardName: award.awardName,
                    awardYear: award.awardYear
                )
            }
        )
    }
}
