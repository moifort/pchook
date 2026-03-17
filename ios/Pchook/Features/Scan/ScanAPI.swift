import Foundation

enum ScanResult {
    case created(Book)
    case duplicate(Book)
}

enum ScanAPI {
    static func scan(imageData: Data) async throws -> ScanResult {
        let (status, response): (Int, APIResponse<Book>) = try await APIClient.shared.postRawWithStatus(
            "/books/scan", data: imageData, contentType: "application/octet-stream", allowedStatuses: [201, 409]
        )
        return status == 409 ? .duplicate(response.data) : .created(response.data)
    }
}
