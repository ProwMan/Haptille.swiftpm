import Foundation

enum PermissionGate {
    static func runOnce(key: String, action: () -> Void) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: key) else { return }
        defaults.set(true, forKey: key)
        action()
    }
}
