import Foundation

enum SharedConfig {
    static let appGroupID = "group.co.polyforms.pchook"
    static let serverURLKey = "serverURL"
    static let defaultURL = "http://172.20.10.2:3000"

    static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }
}
