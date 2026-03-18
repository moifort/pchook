import SwiftUI
@preconcurrency import WebKit

struct AudibleLoginSheet: View {
    let onComplete: () async -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var error: String?
    @State private var loginUrl: String?
    @State private var sessionId: String?
    @State private var cookies: [AuthCookie] = []

    var body: some View {
        NavigationStack {
            Group {
                if let error {
                    ContentUnavailableView("Erreur", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if let loginUrl {
                    AudibleWebView(
                        urlString: loginUrl,
                        cookies: cookies,
                        onAuthCodeReceived: handleAuthCode
                    )
                } else {
                    ProgressView("Chargement...")
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
        .task { await loadLoginUrl() }
    }

    private func loadLoginUrl() async {
        do {
            let response = try await AudibleAPI.authStart()
            loginUrl = response.loginUrl
            sessionId = response.sessionId
            cookies = response.cookies
        } catch {
            self.error = reportError(error)
        }
    }

    private func handleAuthCode(_ redirectUrl: String) {
        guard let sessionId else { return }
        Task {
            do {
                try await AudibleAPI.authCallback(sessionId: sessionId, redirectUrl: redirectUrl)
                await onComplete()
            } catch {
                self.error = reportError(error)
            }
        }
    }
}

struct AudibleWebView: UIViewRepresentable {
    let urlString: String
    let cookies: [AuthCookie]
    let onAuthCodeReceived: (String) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"

        let store = webView.configuration.websiteDataStore.httpCookieStore
        let group = DispatchGroup()
        for cookie in cookies {
            guard let httpCookie = HTTPCookie(properties: [
                .name: cookie.name,
                .value: cookie.value,
                .domain: cookie.domain,
                .path: "/",
            ]) else { continue }
            group.enter()
            store.setCookie(httpCookie) { group.leave() }
        }

        group.notify(queue: .main) {
            guard let url = URL(string: urlString) else { return }
            webView.load(URLRequest(url: url))
        }

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onAuthCodeReceived: onAuthCodeReceived)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        let onAuthCodeReceived: (String) -> Void

        init(onAuthCodeReceived: @escaping (String) -> Void) {
            self.onAuthCodeReceived = onAuthCodeReceived
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            if url.path.contains("maplanding") {
                let urlString = url.absoluteString
                if urlString.contains("openid.oa2.authorization_code") {
                    decisionHandler(.cancel)
                    onAuthCodeReceived(urlString)
                    return
                }
            }

            decisionHandler(.allow)
        }
    }
}
