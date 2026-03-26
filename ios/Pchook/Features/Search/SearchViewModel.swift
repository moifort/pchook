import Foundation

@MainActor @Observable
final class SearchViewModel {
    var searchText = ""
    private(set) var results: SearchResultsData?
    private(set) var isSearching = false

    private var searchTask: Task<Void, Never>?

    var hasResults: Bool {
        guard let results else { return false }
        return !results.isEmpty
    }

    var isActive: Bool {
        !searchText.isEmpty
    }

    func onSearchTextChanged() {
        searchTask?.cancel()

        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            results = nil
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }

    func updateItem(id: String) async {
        guard var data = results,
              let index = data.books.firstIndex(where: { $0.id == id }) else { return }
        do {
            let detail = try await GraphQLBooksAPI.getDetail(id: id)
            data.books[index] = BookSearchResultItem(
                id: detail.book.id,
                title: detail.book.title,
                authors: detail.book.authors,
                language: detail.book.language,
                status: detail.book.status.rawValue,
                coverImageUrl: detail.coverImageUrl
            )
            results = data
        } catch {
            // Silent — worst case stale data until next search
        }
    }

    func removeItem(id: String) {
        guard var data = results else { return }
        data.books.removeAll { $0.id == id }
        results = data
    }

    private func performSearch() async {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else {
            results = nil
            isSearching = false
            return
        }

        do {
            let data = try await GraphQLSearchAPI.search(query: query)
            if !Task.isCancelled {
                results = data
            }
        } catch is CancellationError {
            // Ignored
        } catch {
            results = SearchResultsData(books: [], series: [], authors: [])
        }
        if !Task.isCancelled {
            isSearching = false
        }
    }
}
