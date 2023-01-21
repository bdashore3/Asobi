//
//  Application.swift
//  Asobi
//
//  Created by Brian Dashore on 1/10/23.
//

import Foundation

public class Application {
    static let shared = Application()

    var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }

    var appBuild: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    // Debug = development, Nightly = actions, Release = stable
    var buildType: String {
        #if DEBUG
        return "Debug"
        #else
        return "Release"
        #endif
    }

    let osVersion: OperatingSystemVersion = ProcessInfo().operatingSystemVersion
}
