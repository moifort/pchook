import Foundation

enum ScanStep: Equatable {
    case camera
    case scanning
    case preview(BookPreview)
    case duplicate(existingBookId: String, preview: BookPreview)
    case replacePreview(existingBookId: String, preview: BookPreview)

    static func == (lhs: ScanStep, rhs: ScanStep) -> Bool {
        switch (lhs, rhs) {
        case (.camera, .camera), (.scanning, .scanning): return true
        case (.preview, .preview), (.duplicate, .duplicate), (.replacePreview, .replacePreview): return true
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
                let ocrText = await TextRecognizer.recognizeText(from: imageData)
                let preview = try await GraphQLScanAPI.analyze(imageData: imageData, ocrText: ocrText)
                self.step = .preview(preview)
            } catch {
                self.error = reportError(error)
                self.step = .camera
            }
        }
    }

    func confirm(
        previewId: String,
        status: String,
        overrides: ConfirmBookOverrides? = nil,
        replaceBookId: String? = nil
    ) async -> ConfirmResult? {
        do {
            return try await GraphQLScanAPI.confirm(
                previewId: previewId,
                status: status,
                overrides: overrides,
                replaceBookId: replaceBookId
            )
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
