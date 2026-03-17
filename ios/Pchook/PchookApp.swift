import Sentry
import SwiftUI

@main
struct PchookApp: App {
    init() {
        SharedConfig.sharedDefaults.register(defaults: [SharedConfig.serverURLKey: SharedConfig.defaultURL])
        if let override = UserDefaults.standard.string(forKey: SharedConfig.serverURLKey) {
            SharedConfig.sharedDefaults.set(override, forKey: SharedConfig.serverURLKey)
        }
        startSentry()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func startSentry() {
        let dsn = Secrets.sentryDsn
        if dsn.isEmpty { return }

        SentrySDK.start { options in
            options.dsn = dsn
            options.tracesSampleRate = 1.0
            options.enableAutoSessionTracking = true
            options.enableTimeToFullDisplayTracing = true
            options.tracePropagationTargets = []
        }
    }
}
