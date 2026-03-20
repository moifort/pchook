import PhotosUI
import SentrySwiftUI
import SwiftUI

struct ScanFlowView: View {
    var onFlowCompleted: () -> Void = {}

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ScanViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var shouldCapture = false

    var body: some View {
        Group {
            switch viewModel.step {
            case .camera:
                ZStack {
                    CameraView(onCapture: { data in
                        viewModel.capturePhoto(data)
                    }, shouldCapture: $shouldCapture)
                        .ignoresSafeArea()

                    ViewfinderOverlay()

                    VStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 44, height: 44)
                                    .background(.ultraThinMaterial, in: .circle)
                            }
                            .accessibilityIdentifier("scan-close-button")
                            Spacer()
                        }
                        .padding()
                        Spacer()
                    }

                    VStack {
                        Spacer()
                        HStack {
                            PhotosPicker(
                                selection: $selectedPhoto,
                                matching: .images
                            ) {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                                    .frame(width: 56, height: 56)
                                    .background(.ultraThinMaterial, in: .circle)
                            }
                            .accessibilityIdentifier("scan-photo-picker")
                            Spacer()
                            Button {
                                shouldCapture = true
                            } label: {
                                Circle()
                                    .stroke(.white, lineWidth: 4)
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        Circle()
                                            .fill(.white)
                                            .frame(width: 60, height: 60)
                                    )
                            }
                            .accessibilityIdentifier("scan-capture-button")
                            Spacer()
                            Color.clear.frame(width: 56, height: 56)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                    }
                }

            case .scanning:
                AnalyzingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            case .preview(let preview):
                NavigationStack {
                    ScanConfirmationView(
                        preview: mapPreview(preview),
                        onScanAnother: { viewModel.reset() },
                        onConfirm: { status, overrides in
                            guard let result = await viewModel.confirm(
                                previewId: preview.previewId, status: status, overrides: overrides
                            ) else { return }

                            switch result {
                            case .created:
                                viewModel.reset()
                                onFlowCompleted()
                            case .duplicate(let book):
                                viewModel.step = .duplicate(
                                    existingBookId: book.id, preview: preview
                                )
                            case .replaced:
                                viewModel.reset()
                                onFlowCompleted()
                            }
                        }
                    )
                }

            case .duplicate(_, let preview):
                NavigationStack {
                    ScanDuplicateView(
                        title: preview.title,
                        authors: preview.authors.joined(separator: ", "),
                        onReplace: {
                            if case .duplicate(let existingBookId, let preview) = viewModel.step {
                                viewModel.step = .replacePreview(
                                    existingBookId: existingBookId, preview: preview
                                )
                            }
                        },
                        onScanAnother: { viewModel.reset() },
                        onDismiss: { dismiss() }
                    )
                }

            case .replacePreview(let existingBookId, let preview):
                NavigationStack {
                    ScanConfirmationView(
                        preview: mapPreview(preview),
                        onScanAnother: { viewModel.reset() },
                        onConfirm: { status, overrides in
                            guard let result = await viewModel.confirm(
                                previewId: preview.previewId,
                                status: status,
                                overrides: overrides,
                                replaceBookId: existingBookId
                            ) else { return }

                            switch result {
                            case .replaced, .created:
                                viewModel.reset()
                                onFlowCompleted()
                            case .duplicate:
                                viewModel.reset()
                                onFlowCompleted()
                            }
                        }
                    )
                }
            }
        }
        .sentryTrace("Scan Flow")
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
        .onChange(of: selectedPhoto) {
            guard let item = selectedPhoto else { return }
            selectedPhoto = nil
            viewModel.step = .scanning
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let jpeg = image.resized(maxDimension: 800).jpegData(compressionQuality: 0.6) {
                    viewModel.capturePhoto(jpeg)
                } else {
                    viewModel.step = .camera
                }
            }
        }
        .alert("Erreur", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    private func mapPreview(_ preview: BookPreview) -> ScanConfirmationView.Item {
        let genres = preview.genre?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []

        return .init(
            previewId: preview.previewId,
            title: preview.title,
            authors: preview.authors.joined(separator: ", "),
            genres: genres,
            synopsis: preview.synopsis,
            pageCount: preview.pageCount,
            language: preview.language,
            format: preview.format,
            publisher: preview.publisher,
            translator: preview.translator,
            estimatedPrice: preview.estimatedPrice,
            duration: preview.duration,
            narrators: preview.narrators,
            awards: preview.awards.map { .init(name: $0.name, year: $0.year) },
            ratings: preview.publicRatings.map {
                .init(source: $0.source, score: $0.score, maxScore: $0.maxScore, voterCount: $0.voterCount)
            },
            series: preview.series,
            seriesLabel: preview.seriesLabel,
            seriesNumber: preview.seriesNumber
        )
    }
}
