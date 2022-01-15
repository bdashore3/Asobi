//
//  UIApplicationView.swift
//  Asobi
//
//  Created by Brian Dashore on 9/30/21.
//

import SwiftUI

// Extensions to get the version/build number for AboutView
extension UIApplication {
    class func appVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    class func appBuild() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }

    class func buildType() -> String {
        #if DEBUG
        return "Debug"
        #else
        return "Release"
        #endif
    }
}
