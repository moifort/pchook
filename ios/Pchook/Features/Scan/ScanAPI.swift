import Foundation

enum ConfirmResult {
    case created(Book)
    case duplicate(Book)
}

struct AnalyzeIsbnRequest: Encodable, Sendable {
    let isbn: String
}

struct DuplicateInfo: Decodable, Sendable {
    let bookId: String
    let title: String
    let authors: [String]
}

enum AnalyzeIsbnResponseData: Decodable, Sendable {
    case preview(BookPreview)
    case duplicate(DuplicateInfo)

    private enum CodingKeys: String, CodingKey {
        case bookId, previewId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.bookId) {
            self = .duplicate(try DuplicateInfo(from: decoder))
        } else {
            self = .preview(try BookPreview(from: decoder))
        }
    }
}

enum AnalyzeBarcodeResult {
    case preview(BookPreview)
    case duplicate(bookId: String, title: String, authors: [String])
}

enum ScanAPI {
    static func analyze(imageData: Data) async throws -> BookPreview {
        let response: APIResponse<BookPreview> = try await APIClient.shared.postRaw(
            "/books/analyze", data: imageData, contentType: "application/octet-stream"
        )
        return response.data
    }

    static func confirm(previewId: String, status: String, overrides: ConfirmBookOverrides? = nil) async throws -> ConfirmResult {
        let (statusCode, response): (Int, APIResponse<Book>) = try await APIClient.shared.postWithStatus(
            "/books/confirm",
            body: ConfirmBookRequest(previewId: previewId, status: status, overrides: overrides),
            allowedStatuses: [201, 409]
        )
        return statusCode == 409 ? .duplicate(response.data) : .created(response.data)
    }

    static func analyzeBarcode(isbn: String) async throws -> AnalyzeBarcodeResult {
        let (_, response): (Int, APIResponse<AnalyzeIsbnResponseData>) = try await APIClient.shared.postWithStatus(
            "/books/analyze-isbn",
            body: AnalyzeIsbnRequest(isbn: isbn),
            allowedStatuses: [200, 409]
        )
        switch response.data {
        case .preview(let preview):
            return .preview(preview)
        case .duplicate(let info):
            return .duplicate(bookId: info.bookId, title: info.title, authors: info.authors)
        }
    }
}
