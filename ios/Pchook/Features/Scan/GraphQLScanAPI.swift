import Apollo
import Foundation

enum GraphQLScanAPI {
    private static var client: ApolloClient { GraphQLClient.shared.apollo }

    static func analyze(imageData: Data, ocrText: String?) async throws -> BookPreview {
        let mutation = PchookGraphQL.AnalyzeBookCoverMutation(
            imageBase64: imageData.base64EncodedString(),
            ocrText: ocrText.map { .some($0) } ?? .none
        )
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)

        let preview = data.analyzeBookCover
        return BookPreview(
            previewId: preview.previewId,
            title: preview.title,
            authors: preview.authors,
            publisher: preview.publisher,
            publishedDate: preview.publishedDate,
            pageCount: preview.pageCount,
            genre: preview.genre,
            synopsis: preview.synopsis,
            isbn: preview.isbn,
            language: preview.language,
            format: preview.format,
            series: preview.series,
            seriesLabel: preview.seriesLabel,
            seriesNumber: preview.seriesNumber.map(Int.init),
            translator: preview.translator,
            estimatedPrice: preview.estimatedPrice,
            duration: preview.duration,
            narrators: preview.narrators,
            awards: preview.awards.map { Award(name: $0.name, year: $0.year) },
            publicRatings: preview.publicRatings.map {
                PublicRating(
                    source: $0.source,
                    score: Double($0.score),
                    maxScore: Double($0.maxScore),
                    voterCount: $0.voterCount,
                    url: $0.url
                )
            }
        )
    }

    static func confirm(
        previewId: String,
        status: String,
        overrides: ConfirmBookOverrides? = nil,
        replaceBookId: String? = nil
    ) async throws -> ConfirmResult {
        let input = PchookGraphQL.ConfirmBookInput(
            authors: overrides?.authors.map { .some($0) } ?? .none,
            estimatedPrice: overrides?.estimatedPrice.map { .some($0) } ?? .none,
            format: overrides?.format.map { .some($0) } ?? .none,
            genre: overrides?.genre.map { .some($0) } ?? .none,
            language: overrides?.language
                .flatMap { PchookGraphQL.Language(rawValue: $0) }
                .map { .some(.case($0)) } ?? .none,
            pageCount: overrides?.pageCount.map { .some($0) } ?? .none,
            previewId: previewId,
            publisher: overrides?.publisher.map { .some($0) } ?? .none,
            replaceBookId: replaceBookId.map { .some($0) } ?? .none,
            series: overrides?.series.map { .some($0) } ?? .none,
            seriesLabel: overrides?.seriesLabel.map { .some($0) } ?? .none,
            seriesNumber: overrides?.seriesNumber.map { .some(Double($0)) } ?? .none,
            status: status,
            synopsis: overrides?.synopsis.map { .some($0) } ?? .none,
            title: overrides?.title.map { .some($0) } ?? .none,
            translator: overrides?.translator.map { .some($0) } ?? .none
        )

        let mutation = PchookGraphQL.ConfirmBookMutation(input: input)
        let data = try await GraphQLHelpers.perform(client, mutation: mutation)

        let result = data.confirmBook
        let book = Book(
            id: result.book.id,
            title: result.book.title,
            authors: result.book.authors,
            narrators: [],
            status: BookStatus(rawValue: result.book.status) ?? .toRead,
            awards: [],
            publicRatings: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        switch result.tag {
        case "duplicate": return .duplicate(book)
        case "replaced": return .replaced(book)
        default: return .created(book)
        }
    }
}
