//
//  PermissionGate.swift
//  Haptille
//
//  Created by Madhan on 23/12/25.
//

import Foundation

enum PermissionGate {
    static func runOnce(key: String, action: () -> Void) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: key) else { return }
        defaults.set(true, forKey: key)
        action()
    }
}
