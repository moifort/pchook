import Apollo
import Foundation

enum GraphQLSearchAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func search(query: String, limit: Int = 10) async throws -> SearchResultsData {
        let gqlQuery = PchookGraphQL.SearchQuery(query: query, limit: .some(limit))
        let data = try await GraphQLHelpers.fetch(client, query: gqlQuery)
        return SearchResultsData(
            books: data.search.books.map {
                BookSearchResultItem(
                    id: $0.id,
                    title: $0.title,
                    authors: $0.authors,
                    language: $0.language,
                    status: $0.status,
                    coverImageUrl: $0.coverImageUrl
                )
            },
            series: data.search.series.map {
                SeriesSearchResultItem(
                    id: $0.id,
                    name: $0.name,
                    volumeCount: $0.volumeCount,
                    rating: $0.rating,
                    languages: $0.languages
                )
            },
            authors: data.search.authors.map {
                AuthorSearchResultItem(
                    name: $0.name,
                    bookCount: $0.bookCount,
                    firstBookId: $0.firstBookId
                )
            }
        )
    }
}
