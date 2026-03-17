import SwiftUI

struct ScanConfirmationView: View {
    let title: String
    let authors: String
    let genre: String?
    let onScanAnother: () -> Void
    let onStatusChosen: (String) async -> Void

    @State private var scale = 0.5
    @State private var opacity = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .scaleEffect(scale)
                .opacity(opacity)

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

            VStack(spacing: 12) {
                Button {
                    onScanAnother()
                } label: {
                    Label("Scanner un autre", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("scan-another-button")

                HStack(spacing: 12) {
                    Button {
                        Task { await onStatusChosen("to-read") }
                    } label: {
                        Label("\u{00C0} lire", systemImage: "bookmark.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .accessibilityIdentifier("status-to-read-button")

                    Button {
                        Task { await onStatusChosen("read") }
                    } label: {
                        Label("Lu", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityIdentifier("status-read-button")
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .navigationBarBackButtonHidden()
        .onAppear {
            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScanConfirmationView(
            title: "L'\u{00C9}tranger",
            authors: "Albert Camus",
            genre: "Roman",
            onScanAnother: {},
            onStatusChosen: { _ in }
        )
    }
}
