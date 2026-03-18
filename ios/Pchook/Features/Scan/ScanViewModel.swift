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

    func confirm(previewId: String, status: String, overrides: ConfirmBookOverrides? = nil) async -> ConfirmResult? {
        do {
            return try await ScanAPI.confirm(previewId: previewId, status: status, overrides: overrides)
        } catch {
            self.error = reportError(error)
            return nil
        }
    }

    func scanBarcode(_ isbn: String) {
        step = .scanning
        error = nil

        Task {
            do {
                let result = try await ScanAPI.analyzeBarcode(isbn: isbn)
                switch result {
                case .preview(let preview):
                    self.step = .preview(preview)
                case .duplicate(let bookId, let title, let authors):
                    self.step = .duplicate(bookId: bookId, title: title, authors: authors)
                }
            } catch {
                self.error = reportError(error)
                self.step = .camera
            }
        }
    }

    func reset() {
        step = .camera
        error = nil
    }
}
