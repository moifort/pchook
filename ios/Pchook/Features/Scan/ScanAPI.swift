import Foundation

enum ConfirmResult {
    case created(Book)
    case duplicate(Book)
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

    static func confirm(previewId: String, status: String, overrides: ConfirmBookOverrides? = nil) async throws -> ConfirmResult {
        let (statusCode, response): (Int, APIResponse<Book>) = try await APIClient.shared.postWithStatus(
            "/books/confirm",
            body: ConfirmBookRequest(previewId: previewId, status: status, overrides: overrides),
            allowedStatuses: [201, 409]
        )
        return statusCode == 409 ? .duplicate(response.data) : .created(response.data)
    }
}
