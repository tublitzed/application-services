/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SwiftKeychainWrapper

extension KeychainWrapper {
    /// Return the base bundle identifier.
    ///
    /// This function is smart enough to find out if it is being called from an extension or the main application. In
    /// case of the former, it will chop off the extension identifier from the bundle since that is a suffix not part
    /// of the *base* bundle identifier.
    static var baseBundleIdentifier: String {
        let bundle = Bundle.main
        let baseBundleIdentifier = bundle.bundleIdentifier!

        return baseBundleIdentifier
    }

    /// Return the keychain access group.
    static func keychainAccessGroupWithPrefix(_ prefix: String) -> String {
        let bundleIdentifier = baseBundleIdentifier
        return prefix + "." + bundleIdentifier
    }

    static var shared: KeychainWrapper?

    static func sharedAppContainerKeychain(accessGroupPrefix: String? = nil) -> KeychainWrapper {
        if let s = shared {
            return s
        }
        let accessGroup = accessGroupPrefix.map { keychainAccessGroupWithPrefix($0) }
        let wrapper = KeychainWrapper(serviceName: baseBundleIdentifier, accessGroup: accessGroup)
        shared = wrapper
        return wrapper
    }
}
