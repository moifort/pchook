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
    private let rawText: String?
    private let attachmentTypes: [String]
    private let onDismiss: () -> Void

    init(url: URL, description: String?, rawText: String?, attachmentTypes: [String], onDismiss: @escaping () -> Void) {
        self.url = url
        self.description = description
        self.rawText = rawText
        self.attachmentTypes = attachmentTypes
        self.onDismiss = onDismiss
    }

    func start() {
        step = .analyzing
        Task {
            do {
                let preview = try await ShareAPIClient.analyzeUrl(
                    url,
                    description: description,
                    rawText: rawText,
                    attachmentTypes: attachmentTypes
                )
                step = .preview(preview)
            } catch {
                step = .error(message: error.localizedDescription)
            }
        }
    }

    func confirm(previewId: String, status: String, overrides: ShareConfirmOverrides? = nil) {
        isConfirming = true
        Task {
            do {
                try await ShareAPIClient.confirm(previewId: previewId, status: status, overrides: overrides)
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
