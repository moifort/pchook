import Foundation

enum ScanAPI {
    static func scan(imageData: Data) async throws -> Book {
        let response: APIResponse<Book> = try await APIClient.shared.postRaw(
            "/books/scan", data: imageData, contentType: "application/octet-stream"
        )
        return response.data
    }
}
