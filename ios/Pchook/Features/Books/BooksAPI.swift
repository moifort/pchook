import Foundation

enum BooksAPI {
    static func list(genre: String? = nil, status: String? = nil, sort: String? = nil, order: String? = nil) async throws -> [BookListItem] {
        var query: [String: String] = [:]
        if let genre { query["genre"] = genre }
        if let status { query["status"] = status }
        if let sort { query["sort"] = sort }
        if let order { query["order"] = order }
        let response: APIResponse<[BookListItem]> = try await APIClient.shared.get("/books", query: query)
        return response.data
    }

    static func getDetail(id: String) async throws -> BookDetailData {
        let response: APIResponse<BookDetailData> = try await APIClient.shared.get("/books/\(id)")
        return response.data
    }

    static func update(id: String, _ request: UpdateBookRequest) async throws -> Book {
        let response: APIResponse<Book> = try await APIClient.shared.put("/books/\(id)", body: request)
        return response.data
    }

    static func delete(id: String) async throws {
        try await APIClient.shared.delete("/books/\(id)")
    }

    static func addToFavorites(id: String) async throws {
        struct Empty: Encodable, Sendable {}
        struct Ignored: Decodable, Sendable {}
        let _: APIResponse<Ignored> = try await APIClient.shared.post("/books/\(id)/favorite", body: Empty())
    }

    static func addReview(id: String, _ request: CreateReviewRequest) async throws {
        struct Ignored: Decodable, Sendable {}
        let _: APIResponse<Ignored> = try await APIClient.shared.post("/books/\(id)/review", body: request)
    }

}
