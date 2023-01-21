//
//  SettingsModels.swift
//  Asobi
//
//  Created by Brian Dashore on 1/10/23.
//

import Foundation

enum StatusBarStyleType: String, CaseIterable {
    case theme
    case automatic
    case accent
    case custom
}

enum StatusBarBehaviorType: String, CaseIterable {
    case hide
    case partialHide
    case pin
}

enum DefaultSearchEngine: String, CaseIterable {
    case google
    case brave
    case bing
    case duckduckgo
    case startpage
    case custom
}
