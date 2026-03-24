import Apollo
import Foundation

private func graphQLNullable<T>(_ value: T?) -> GraphQLNullable<T> {
    value.map { .some($0) } ?? .none
}

enum GraphQLBooksAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func list(
        genre: String? = nil, status: String? = nil,
        sort: String? = nil, order: String? = nil
    ) async throws -> [BookListItem] {
        let query = PchookGraphQL.BookListQuery(
            genre: graphQLNullable(genre),
            status: graphQLNullable(status),
            sort: sort.flatMap { PchookGraphQL.BookSort(rawValue: $0) }.map { .some(.case($0)) } ?? .none,
            order: order.flatMap { PchookGraphQL.SortOrder(rawValue: $0) }.map { .some(.case($0)) } ?? .none
        )

        let data = try await fetch(query)
        return (data.books ?? []).map { mapBookListItem($0) }
    }

    static func getDetail(id: String) async throws -> BookDetailData {
        let query = PchookGraphQL.BookDetailQuery(id: id)
        let data = try await fetch(query)

        guard let book = data.book else {
            throw APIError.httpError(404)
        }

        return BookDetailData(
            book: mapBook(book),
            coverImageBase64: book.coverImageBase64,
            series: book.series.map { series in
                SeriesInfo(
                    name: series.name ?? "",
                    label: series.label ?? "",
                    position: Double(series.position ?? 0),
                    books: (series.books ?? []).map { entry in
                        SeriesBookEntry(
                            id: entry.id ?? "",
                            title: entry.title ?? "",
                            label: entry.label ?? "",
                            position: Double(entry.position ?? 0)
                        )
                    }
                )
            },
            review: book.review.map { review in
                ReviewInfo(
                    bookId: review.bookId ?? "",
                    rating: review.rating ?? 0,
                    readDate: review.readDate.flatMap(parseISO8601Optional),
                    reviewNotes: review.reviewNotes,
                    createdAt: parseISO8601(review.createdAt)
                )
            }
        )
    }

    static func update(id: String, _ request: UpdateBookRequest) async throws -> Book {
        let statusEnum: GraphQLNullable<GraphQLEnum<PchookGraphQL.BookStatus>> = request.status
            .flatMap { PchookGraphQL.BookStatus(rawValue: statusToGraphQL($0)) }
            .map { .some(.case($0)) } ?? .none

        let input = PchookGraphQL.UpdateBookInput(
            authors: graphQLNullable(request.authors),
            genre: graphQLNullable(request.genre),
            publisher: graphQLNullable(request.publisher),
            series: graphQLNullable(request.series),
            seriesLabel: graphQLNullable(request.seriesLabel),
            seriesNumber: request.seriesNumber.map { .some(Double($0)) } ?? .none,
            status: statusEnum,
            title: graphQLNullable(request.title)
        )

        let mutation = PchookGraphQL.UpdateBookMutation(id: id, input: input)
        _ = try await perform(mutation)

        return try await getDetail(id: id).book
    }

    static func delete(id: String) async throws {
        let mutation = PchookGraphQL.DeleteBookMutation(id: id)
        _ = try await perform(mutation)
    }

    static func addToFavorites(id: String) async throws {
        let mutation = PchookGraphQL.AddToFavoritesMutation(id: id)
        _ = try await perform(mutation)
    }

    static func addReview(id: String, _ request: CreateReviewRequest) async throws {
        let input = PchookGraphQL.CreateReviewInput(
            rating: request.rating,
            readDate: graphQLNullable(request.readDate),
            reviewNotes: graphQLNullable(request.reviewNotes)
        )
        let mutation = PchookGraphQL.AddReviewMutation(bookId: id, input: input)
        _ = try await perform(mutation)
    }

    static func refresh(id: String) async throws {
        let mutation = PchookGraphQL.RefreshBookMutation(id: id)
        _ = try await perform(mutation)
    }
}

// MARK: - Apollo helpers

private extension GraphQLBooksAPI {
    static func fetch<Q: GraphQLQuery>(_ query: Q) async throws -> Q.Data {
        try await withCheckedThrowingContinuation { continuation in
            client.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors, !errors.isEmpty {
                        continuation.resume(throwing: APIError.httpError(422))
                        return
                    }
                    guard let data = graphQLResult.data else {
                        continuation.resume(throwing: APIError.invalidResponse)
                        return
                    }
                    nonisolated(unsafe) let sendableData = data
                    continuation.resume(returning: sendableData)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    static func perform<M: GraphQLMutation>(_ mutation: M) async throws -> M.Data {
        try await withCheckedThrowingContinuation { continuation in
            client.perform(mutation: mutation) { result in
                switch result {
                case .success(let graphQLResult):
                    if let errors = graphQLResult.errors, !errors.isEmpty {
                        continuation.resume(throwing: APIError.httpError(422))
                        return
                    }
                    guard let data = graphQLResult.data else {
                        continuation.resume(throwing: APIError.invalidResponse)
                        return
                    }
                    nonisolated(unsafe) let sendableData = data
                    continuation.resume(returning: sendableData)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Type mapping

private extension GraphQLBooksAPI {
    static func mapBookStatus(_ status: GraphQLEnum<PchookGraphQL.BookStatus>?) -> String {
        guard let status else { return "to-read" }
        switch status {
        case .case(.read): return "read"
        case .case(.toRead): return "to-read"
        default: return "to-read"
        }
    }

    static func statusToGraphQL(_ status: String) -> String {
        status == "read" ? "READ" : "TO_READ"
    }

    static func parseISO8601(_ string: String?) -> Date {
        guard let string else { return Date() }
        return parseISO8601Optional(string) ?? Date()
    }

    static func parseISO8601Optional(_ string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: string) ?? {
            let basic = ISO8601DateFormatter()
            basic.formatOptions = [.withInternetDateTime]
            return basic.date(from: string)
        }()
    }

    static func mapBookListItem(_ book: PchookGraphQL.BookListQuery.Data.Book) -> BookListItem {
        let awards = (book.awards ?? []).map { Award(name: $0.name ?? "", year: $0.year) }
        let position: Double? = book.seriesPosition.map { Double($0) }
        return BookListItem(
            id: book.id ?? "",
            title: book.title ?? "",
            authors: book.authors ?? [],
            genre: book.genre,
            status: mapBookStatus(book.status),
            estimatedPrice: book.estimatedPrice,
            language: book.language,
            awards: awards,
            rating: book.rating,
            seriesName: book.seriesName,
            seriesLabel: book.seriesLabel,
            seriesPosition: position,
            createdAt: parseISO8601(book.createdAt)
        )
    }

    static func mapBook(_ book: PchookGraphQL.BookDetailQuery.Data.Book) -> Book {
        Book(
            id: book.id ?? "",
            title: book.title ?? "",
            authors: book.authors ?? [],
            publisher: book.publisher,
            publishedDate: book.publishedDate.flatMap(parseISO8601Optional),
            pageCount: book.pageCount,
            genre: book.genre,
            synopsis: book.synopsis,
            isbn: book.isbn,
            language: book.language,
            format: book.format?.rawValue,
            translator: book.translator,
            estimatedPrice: book.estimatedPrice,
            duration: book.duration,
            narrators: book.narrators ?? [],
            personalNotes: book.personalNotes,
            status: mapBookStatus(book.status),
            readDate: book.readDate.flatMap(parseISO8601Optional),
            awards: (book.awards ?? []).map { Award(name: $0.name ?? "", year: $0.year) },
            publicRatings: (book.publicRatings ?? []).map {
                PublicRating(
                    source: $0.source ?? "",
                    score: $0.score ?? 0,
                    maxScore: $0.maxScore ?? 0,
                    voterCount: $0.voterCount ?? 0,
                    url: $0.url
                )
            },
            importSource: book.importSource?.rawValue,
            externalUrl: book.externalUrl,
            createdAt: parseISO8601(book.createdAt),
            updatedAt: parseISO8601(book.updatedAt)
        )
    }
}
