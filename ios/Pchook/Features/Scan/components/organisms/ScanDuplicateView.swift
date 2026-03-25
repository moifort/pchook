import SwiftUI

struct ScanDuplicateView: View {
    let title: String
    let authors: String
    let onReplace: () -> Void
    let onScanAnother: () -> Void
    let onDismiss: () -> Void

    @State private var scale = 0.5
    @State private var opacity = 0.0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
                .scaleEffect(scale)
                .opacity(opacity)

            Text("Livre d\u{00E9}j\u{00E0} ajout\u{00E9}")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(authors)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    onReplace()
                } label: {
                    Label("Remplacer", systemImage: "arrow.triangle.2.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.large)

                Button {
                    onScanAnother()
                } label: {
                    Label("Scanner un autre", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)

                Button {
                    onDismiss()
                } label: {
                    Text("Fermer")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
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
        ScanDuplicateView(
            title: "L'\u{00C9}tranger",
            authors: "Albert Camus",
            onReplace: {},
            onScanAnother: {},
            onDismiss: {}
        )
    }
}
