//
//  UIApplicationView.swift
//  Cubari
//
//  Created by Brian Dashore on 9/30/21.
//

import SwiftUI

// Extensions to get the version/build number for AboutView
extension UIApplication {
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
  
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}
