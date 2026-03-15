import Foundation

enum ScanStep: Equatable {
    case camera
    case scanning
    case confirmed(bookId: String, title: String, authors: [String], genre: String?)

    static func == (lhs: ScanStep, rhs: ScanStep) -> Bool {
        switch (lhs, rhs) {
        case (.camera, .camera), (.scanning, .scanning): return true
        case (.confirmed, .confirmed): return true
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
                let book = try await ScanAPI.scan(imageData: imageData)
                self.step = .confirmed(
                    bookId: book.id,
                    title: book.title,
                    authors: book.authors,
                    genre: book.genre
                )
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
