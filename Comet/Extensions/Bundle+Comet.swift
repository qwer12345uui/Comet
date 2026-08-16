//
//  Bundle+Comet.swift
//  Comet
//
//  Created by Noah Little on 12/4/2023.
//

import Foundation

#if ROOTHIDE
@_silgen_name("jbroot")
private func cometJBRoot(_ path: NSString) -> NSString
#endif

internal extension Bundle {
    static var comet: Bundle {
        let relativePath = "/Library/Frameworks/Comet.framework/Resources.bundle/"
        #if ROOTHIDE
        // RootHide randomizes jbroot. Resolve the bootstrap path at runtime.
        let path = cometJBRoot(relativePath as NSString) as String
        #elseif ROOTLESS
        let path = "/var/jb" + relativePath
        #else
        let path = relativePath
        #endif
        
        if let bundle = Bundle(path: path) {
            NSLog("[Comet]: Bundle (\(path)): loaded")
            return bundle
        } else {
            NSLog("[Comet]: Bundle (\(path)): not loaded")
            return .main
        }
    }
}
