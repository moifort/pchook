import Foundation

enum ScanStep: Equatable {
    case camera
    case scanning
    case preview(BookPreview)
    case duplicate(bookId: String, title: String, authors: [String])

    static func == (lhs: ScanStep, rhs: ScanStep) -> Bool {
        switch (lhs, rhs) {
        case (.camera, .camera), (.scanning, .scanning): return true
        case (.preview, .preview), (.duplicate, .duplicate): return true
        default: return false
        }
    }
}

@MainActor @Observable
final class ScanViewModel {
    var step: ScanStep = .camera
    var error: String?

    func capturePhoto(_ imageData: Data) {
        step = .scanning
        error = nil

        Task {
            do {
                let preview = try await ScanAPI.analyze(imageData: imageData)
                self.step = .preview(preview)
            } catch {
                self.error = reportError(error)
                self.step = .camera
            }
        }
    }

    func confirm(previewId: String, status: String) async -> ConfirmResult? {
        do {
            return try await ScanAPI.confirm(previewId: previewId, status: status)
        } catch {
            self.error = reportError(error)
            return nil
        }
    }

    func reset() {
        step = .camera
        error = nil
    }
}
