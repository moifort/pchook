import Foundation

enum SharedConfig {
    static let appGroupID = "group.com.example.pchook"
    static let serverURLKey = "serverURL"
    static let defaultURL = "http://localhost:3000"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID)!
    }
}
