import Foundation

enum ShareStep: Equatable {
    case analyzing
    case success(title: String, authors: String, genre: String?)
    case error(message: String)

    static func == (lhs: ShareStep, rhs: ShareStep) -> Bool {
        switch (lhs, rhs) {
        case (.analyzing, .analyzing): true
        case (.success, .success): true
        case (.error, .error): true
        default: false
        }
    }
}

@MainActor @Observable
final class ShareViewModel {
    var step: ShareStep = .analyzing

    private let url: URL
    private let onDismiss: () -> Void

    init(url: URL, onDismiss: @escaping () -> Void) {
        self.url = url
        self.onDismiss = onDismiss
    }

    func start() {
        step = .analyzing
        Task {
            do {
                let book = try await ShareAPIClient.importUrl(url)
                step = .success(
                    title: book.title,
                    authors: book.authors.joined(separator: ", "),
                    genre: book.genre
                )
            } catch {
                step = .error(message: error.localizedDescription)
            }
        }
    }

    func retry() {
        start()
    }

    func dismiss() {
        onDismiss()
    }
}
