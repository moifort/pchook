import Foundation

enum ConfirmResult {
    case created(Book)
    case duplicate(Book)
}

enum ScanAPI {
    static func analyze(imageData: Data) async throws -> BookPreview {
        let response: APIResponse<BookPreview> = try await APIClient.shared.postRaw(
            "/books/analyze", data: imageData, contentType: "application/octet-stream"
        )
        return response.data
    }

    static func confirm(previewId: String, status: String) async throws -> ConfirmResult {
        let (statusCode, response): (Int, APIResponse<Book>) = try await APIClient.shared.postWithStatus(
            "/books/confirm",
            body: ConfirmBookRequest(previewId: previewId, status: status),
            allowedStatuses: [201, 409]
        )
        return statusCode == 409 ? .duplicate(response.data) : .created(response.data)
    }
}
