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
