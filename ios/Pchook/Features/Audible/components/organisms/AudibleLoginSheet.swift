import SwiftUI
import UIKit

struct AudibleLoginSheet: View {
    let onComplete: () async -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var error: String?
    @State private var sessionId: String?
    @State private var step: AuthStep = .loading

    private enum AuthStep {
        case loading
        case openSafari
        case waitingForUrl
        case processing
    }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .loading:
                    ProgressView("Préparation...")
                case .openSafari:
                    safariInstructions
                case .waitingForUrl:
                    pasteInstructions
                case .processing:
                    ProgressView("Connexion en cours...")
                }
            }
            .navigationTitle("Connexion Audible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .alert("Erreur", isPresented: .constant(error != nil)) {
                Button("OK") { error = nil }
            } message: {
                if let error { Text(error) }
            }
        }
        .task { await prepareLogin() }
    }

    private var safariInstructions: some View {
        ContentUnavailableView {
            Label("Connexion Amazon", systemImage: "safari")
        } description: {
            Text("Safari va s'ouvrir pour vous connecter à Amazon. Après la connexion, vous arriverez sur une page d'erreur — c'est normal.\n\nCopiez l'URL de la barre d'adresse, puis revenez ici.")
        } actions: {
            Button("Ouvrir Safari") {
                step = .waitingForUrl
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var pasteInstructions: some View {
        ContentUnavailableView {
            Label("Coller l'URL", systemImage: "doc.on.clipboard")
        } description: {
            Text("Connectez-vous à Amazon dans Safari, puis copiez l'URL de la page d'erreur et revenez ici.")
        } actions: {
            Button("Coller l'URL copiée") {
                Task { await handlePaste() }
            }
            .buttonStyle(.borderedProminent)
            .disabled(step == .processing)
        }
    }

    private func prepareLogin() async {
        do {
            let response = try await GraphQLAudibleAPI.authStart()
            sessionId = response.sessionId
            guard let url = URL(string: response.loginUrl) else {
                error = "URL de connexion invalide"
                return
            }
            step = .openSafari
            await UIApplication.shared.open(url)
        } catch {
            self.error = reportError(error)
        }
    }

    private func handlePaste() async {
        guard let sessionId else { return }
        guard let pastedUrl = UIPasteboard.general.string, pastedUrl.contains("maplanding") else {
            error = "L'URL copiée ne semble pas être la bonne. Copiez l'URL complète de la barre d'adresse Safari après la connexion."
            return
        }

        step = .processing
        do {
            try await GraphQLAudibleAPI.authCallback(sessionId: sessionId, redirectUrl: pastedUrl)
            await onComplete()
        } catch {
            step = .waitingForUrl
            self.error = reportError(error)
        }
    }
}

#Preview("Safari instructions") {
    AudibleLoginSheet(onComplete: {})
}
