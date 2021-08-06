//
//  CubariApp.swift
//  Cubari
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import PartialSheet

@main
struct CubariApp: App {
    var sheetManager: PartialSheetManager
    
    init() {
        sheetManager = PartialSheetManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sheetManager)
        }
    }
}

// Used for fetching the version string of the app
extension UIApplication {
    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
  
    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    }
}
