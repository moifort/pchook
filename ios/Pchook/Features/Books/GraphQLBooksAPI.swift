import Apollo
import Foundation

private func graphQLNullable<T>(_ value: T?) -> GraphQLNullable<T> {
    value.map { .some($0) } ?? .none
}

enum GraphQLBooksAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func list(
        genre: String? = nil, status: String? = nil,
        sort: String? = nil, order: String? = nil,
        isFavorite: Bool? = nil, hasSeries: Bool? = nil,
        offset: Int? = nil, limit: Int? = nil
    ) async throws -> BookListPage {
        let query = PchookGraphQL.BookListQuery(
            genre: graphQLNullable(genre),
            status: graphQLNullable(status),
            sort: sort.flatMap { PchookGraphQL.BookSort(rawValue: $0) }.map { .some(.case($0)) } ?? .none,
            order: order.flatMap { PchookGraphQL.SortOrder(rawValue: $0) }.map { .some(.case($0)) } ?? .none,
            isFavorite: isFavorite.map { .some($0) } ?? .none,
            hasSeries: hasSeries.map { .some($0) } ?? .none,
            offset: offset.map { .some($0) } ?? .none,
            limit: limit.map { .some($0) } ?? .none
        )

        let data = try await GraphQLHelpers.fetch(client, query: query)
        return BookListPage(
            items: data.books.items.map { mapBookListItem($0) },
            totalCount: data.books.totalCount,
            hasMore: data.books.hasMore
        )
    }

    static func getDetail(id: String) async throws -> BookDetailData {
        let query = PchookGraphQL.BookDetailQuery(id: id)
        let data = try await GraphQLHelpers.fetch(client, query: query)

        guard let book = data.book else {
            throw APIError.httpError(404)
        }

        return BookDetailData(
            book: mapBook(book),
            coverImageUrl: book.coverImageUrl,
            series: book.series.map { series in
                Series(
                    id: series.id,
                    name: series.name,
                    rating: series.rating,
                    volumes: series.volumes.map { entry in
                        SeriesVolume(
                            id: entry.id,
                            title: entry.title,
                            label: entry.label,
                            position: Double(entry.position)
                        )
                    }
                )
            },
            seriesVolume: book.seriesVolume.map { volume in
                SeriesVolume(
                    id: volume.id,
                    title: volume.title,
                    label: volume.label,
                    position: Double(volume.position)
                )
            },
            review: book.review.map { review in
                ReviewInfo(
                    bookId: review.bookId,
                    rating: review.rating,
                    readDate: review.readDate.flatMap(GraphQLHelpers.parseISO8601),
                    reviewNotes: review.reviewNotes,
                    createdAt: GraphQLHelpers.parseISO8601(review.createdAt) ?? Date()
                )
            }
        )
    }

    static func update(id: String, _ request: UpdateBookRequest) async throws -> Book {
        let languageEnum: GraphQLNullable<GraphQLEnum<PchookGraphQL.Language>> = request.language
            .flatMap { PchookGraphQL.Language(rawValue: $0) }
            .map { .some(.case($0)) } ?? .none

        let input = PchookGraphQL.UpdateBookInput(
            authors: graphQLNullable(request.authors),
            durationMinutes: request.durationMinutes.map { .some($0) } ?? .none,
            genre: graphQLNullable(request.genre),
            language: languageEnum,
            narrators: graphQLNullable(request.narrators),
            publisher: graphQLNullable(request.publisher),
            series: graphQLNullable(request.series),
            seriesLabel: graphQLNullable(request.seriesLabel),
            seriesNumber: request.seriesNumber.map { .some(Double($0)) } ?? .none,
            status: graphQLNullable(request.status),
            title: graphQLNullable(request.title)
        )

        let mutation = PchookGraphQL.UpdateBookMutation(id: id, input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)

        return try await getDetail(id: id).book
    }

    static func delete(id: String) async throws {
        let mutation = PchookGraphQL.DeleteBookMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func addToFavorites(id: String) async throws {
        let mutation = PchookGraphQL.AddToFavoritesMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func addReview(id: String, _ request: CreateReviewRequest) async throws {
        let input = PchookGraphQL.CreateReviewInput(
            rating: request.rating,
            readDate: graphQLNullable(request.readDate),
            reviewNotes: graphQLNullable(request.reviewNotes)
        )
        let mutation = PchookGraphQL.AddReviewMutation(bookId: id, input: input)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func refresh(id: String) async throws {
        let mutation = PchookGraphQL.RefreshBookMutation(id: id)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }

    static func rateSeries(id: String, rating: Int) async throws {
        let mutation = PchookGraphQL.RateSeriesMutation(id: id, rating: rating)
        _ = try await GraphQLHelpers.perform(client, mutation: mutation)
    }
}

// MARK: - Type mapping

private extension GraphQLBooksAPI {
    static func mapBookFormat(_ format: GraphQLEnum<PchookGraphQL.BookFormat>?) -> BookFormat? {
        guard let format else { return nil }
        return BookFormat(rawValue: format.rawValue)
    }

    static func mapImportSource(_ source: GraphQLEnum<PchookGraphQL.ImportSource>?) -> ImportSource? {
        guard let source else { return nil }
        return ImportSource(rawValue: source.rawValue)
    }

    static func mapBookListItem(_ book: PchookGraphQL.BookListQuery.Data.Books.Item) -> BookListItem {
        let awards = (book.awards).map { Award(name: $0.name, year: $0.year) }
        return BookListItem(
            id: book.id,
            title: book.title,
            coverImageUrl: book.coverImageUrl,
            authors: book.authors,
            genre: book.genre,
            status: BookStatus(rawValue: book.status) ?? .toRead,
            estimatedPrice: book.estimatedPrice,
            awards: awards,
            rating: book.review?.rating,
            language: book.language?.rawValue,
            seriesName: book.series?.name,
            seriesLabel: book.seriesVolume?.label,
            seriesPosition: book.seriesVolume.map { Double($0.position) },
            createdAt: GraphQLHelpers.parseISO8601(book.createdAt) ?? Date()
        )
    }

    static func mapBook(_ book: PchookGraphQL.BookDetailQuery.Data.Book) -> Book {
        Book(
            id: book.id,
            title: book.title,
            authors: book.authors,
            publisher: book.publisher,
            publishedDate: book.publishedDate.flatMap(GraphQLHelpers.parseISO8601),
            pageCount: book.pageCount,
            genre: book.genre,
            synopsis: book.synopsis,
            isbn: book.isbn,
            language: book.language?.rawValue,
            format: mapBookFormat(book.format),
            translator: book.translator,
            estimatedPrice: book.estimatedPrice,
            durationMinutes: book.durationMinutes,
            narrators: book.narrators,
            personalNotes: book.personalNotes,
            status: BookStatus(rawValue: book.status) ?? .toRead,
            readDate: book.readDate.flatMap(GraphQLHelpers.parseISO8601),
            awards: book.awards.map { Award(name: $0.name, year: $0.year) },
            publicRatings: book.publicRatings.map {
                PublicRating(
                    source: $0.source,
                    score: Double($0.score),
                    maxScore: Double($0.maxScore),
                    voterCount: $0.voterCount,
                    url: $0.url
                )
            },
            importSource: mapImportSource(book.importSource),
            externalUrl: book.externalUrl,
            createdAt: GraphQLHelpers.parseISO8601(book.createdAt) ?? Date(),
            updatedAt: GraphQLHelpers.parseISO8601(book.updatedAt) ?? Date()
        )
    }
}
