import Foundation

enum ConfirmResult {
    case created(Book)
    case duplicate(Book)
    case replaced(Book)
}

enum ScanAPI {
    static func analyze(imageData: Data, ocrText: String?) async throws -> BookPreview {
        let request = AnalyzeBookRequest(
            imageBase64: imageData.base64EncodedString(),
            ocrText: ocrText
        )
        let response: APIResponse<BookPreview> = try await APIClient.shared.post(
            "/books/analyze", body: request
        )
        return response.data
    }

    static func confirm(
        previewId: String,
        status: String,
        overrides: ConfirmBookOverrides? = nil,
        replaceBookId: String? = nil
    ) async throws -> ConfirmResult {
        let (statusCode, response): (Int, APIResponse<Book>) = try await APIClient.shared.postWithStatus(
            "/books/confirm",
            body: ConfirmBookRequest(
                previewId: previewId,
                status: status,
                overrides: overrides,
                replaceBookId: replaceBookId
            ),
            allowedStatuses: [200, 201, 409]
        )
        switch statusCode {
        case 409: return .duplicate(response.data)
        case 200: return .replaced(response.data)
        default: return .created(response.data)
        }
    }
}
