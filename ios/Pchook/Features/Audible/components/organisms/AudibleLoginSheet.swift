import AuthenticationServices
import SwiftUI

struct AudibleLoginSheet: View {
    let onComplete: () async -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Group {
                if let error {
                    ContentUnavailableView(
                        "Erreur",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else {
                    ProgressView("Connexion à Amazon...")
                }
            }
            .navigationTitle("Connexion Audible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
        .task { await startAuth() }
    }

    private func startAuth() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await AudibleAPI.authStart()
            guard let loginUrl = URL(string: response.loginUrl) else {
                error = "URL de connexion invalide"
                return
            }

            let callbackUrl = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
                let session = ASWebAuthenticationSession(
                    url: loginUrl,
                    callbackURLScheme: "pchook"
                ) { callbackURL, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let callbackURL {
                        continuation.resume(returning: callbackURL)
                    } else {
                        continuation.resume(throwing: AuthError.noCallback)
                    }
                }
                session.prefersEphemeralWebBrowserSession = false
                session.presentationContextProvider = PresentationContextProvider.shared
                session.start()
            }

            try await AudibleAPI.authCallback(
                sessionId: response.sessionId,
                redirectUrl: callbackUrl.absoluteString
            )
            await onComplete()
        } catch let error as ASWebAuthenticationSessionError where error.code == .canceledLogin {
            dismiss()
        } catch {
            self.error = reportError(error)
        }
    }
}

private enum AuthError: LocalizedError {
    case noCallback

    var errorDescription: String? {
        switch self {
        case .noCallback: "Aucune réponse d'authentification reçue"
        }
    }
}

private final class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding, @unchecked Sendable {
    static let shared = PresentationContextProvider()

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first
        else {
            return ASPresentationAnchor()
        }
        return window
    }
}
