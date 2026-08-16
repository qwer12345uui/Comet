//
//  Bundle+Comet.swift
//  Comet
//
//  Created by Noah Little on 12/4/2023.
//

import Foundation
import libroot

internal extension Bundle {
    static var comet: Bundle {
        // libroot resolves the jailbreak prefix at runtime, including RootHide's
        // randomized jbroot. This avoids a fixed bootstrap prefix in Swift.
        let path = jbRootPath("/Library/Frameworks/Comet.framework/Resources.bundle/")

        if let bundle = Bundle(path: path) {
            NSLog("[Comet]: Bundle (\(path)): loaded")
            return bundle
        } else {
            NSLog("[Comet]: Bundle (\(path)): not loaded")
            return .main
        }
    }
}
