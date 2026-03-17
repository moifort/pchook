import SwiftUI

struct ShareView: View {
    @State var viewModel: ShareViewModel

    var body: some View {
        Group {
            switch viewModel.step {
            case .analyzing:
                analyzingContent

            case .success(let title, let authors, let genre):
                successContent(title: title, authors: authors, genre: genre)

            case .error(let message):
                errorContent(message: message)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
        .onAppear {
            viewModel.start()
        }
    }

    private var analyzingContent: some View {
        VStack(spacing: 32) {
            Spacer()

            ProgressView()
                .scaleEffect(2)

            VStack(spacing: 12) {
                Text("Analyse en cours")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Identification du livre...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @State private var checkmarkScale = 0.5
    @State private var checkmarkOpacity = 0.0

    private func successContent(title: String, authors: String, genre: String?) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .scaleEffect(checkmarkScale)
                .opacity(checkmarkOpacity)

            Text("Livre ajout\u{00E9} !")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(authors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let genre {
                    Text(genre)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(.capsule)
                }
            }

            Spacer()

            Button {
                viewModel.dismiss()
            } label: {
                Text("Termin\u{00E9}")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
        }
    }

    private func errorContent(message: String) -> some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text("Erreur")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    viewModel.retry()
                } label: {
                    Label("R\u{00E9}essayer", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    viewModel.dismiss()
                } label: {
                    Text("Annuler")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
