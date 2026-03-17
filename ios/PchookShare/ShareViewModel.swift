import Foundation

enum ShareStep: Equatable {
    case analyzing
    case preview(ShareBookPreview)
    case error(message: String)

    static func == (lhs: ShareStep, rhs: ShareStep) -> Bool {
        switch (lhs, rhs) {
        case (.analyzing, .analyzing): true
        case (.preview, .preview): true
        case (.error, .error): true
        default: false
        }
    }
}

@MainActor @Observable
final class ShareViewModel {
    var step: ShareStep = .analyzing
    var isConfirming = false

    private let url: URL
    private let description: String?
    private let onDismiss: () -> Void

    init(url: URL, description: String?, onDismiss: @escaping () -> Void) {
        self.url = url
        self.description = description
        self.onDismiss = onDismiss
    }

    func start() {
        step = .analyzing
        Task {
            do {
                let preview = try await ShareAPIClient.analyzeUrl(url, description: description)
                step = .preview(preview)
            } catch {
                step = .error(message: error.localizedDescription)
            }
        }
    }

    func confirm(previewId: String, status: String) {
        isConfirming = true
        Task {
            do {
                try await ShareAPIClient.confirm(previewId: previewId, status: status)
                onDismiss()
            } catch {
                isConfirming = false
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
