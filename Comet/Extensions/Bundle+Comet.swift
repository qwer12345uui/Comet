//
//  Bundle+Comet.swift
//  Comet
//
//  Created by Noah Little on 12/4/2023.
//

import Foundation

internal extension Bundle {
    static var comet: Bundle {
        // The bridge resolves this jailbreak-relative path through jbroot() for
        // RootHide and through the standard rootless prefix for other schemes.
        let path = CometJailbreakPath("/Library/Frameworks/Comet.framework/Resources.bundle/")

        if let bundle = Bundle(path: path) {
            NSLog("[Comet]: Bundle (\(path)): loaded")
            return bundle
        } else {
            NSLog("[Comet]: Bundle (\(path)): not loaded")
            return .main
        }
    }
}
