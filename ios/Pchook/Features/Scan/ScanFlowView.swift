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

            case .confirmed(let bookId, let title, let authors, let genre):
                NavigationStack {
                    ScanConfirmationView(
                        title: title,
                        authors: authors.joined(separator: ", "),
                        genre: genre,
                        onScanAnother: { viewModel.reset() },
                        onStatusChosen: { status in
                            if status == "read" {
                                _ = try? await BooksAPI.update(id: bookId, UpdateBookRequest(status: "read"))
                            }
                            viewModel.reset()
                            onFlowCompleted()
                        }
                    )
                }

            case .duplicate(_, let title, let authors):
                NavigationStack {
                    ScanDuplicateView(
                        title: title,
                        authors: authors.joined(separator: ", "),
                        onScanAnother: { viewModel.reset() },
                        onDismiss: { dismiss() }
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
}
