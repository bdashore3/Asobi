//
//  StatusBarBehaviorPicker.swift
//  Asobi
//
//  Created by Brian Dashore on 4/7/22.
//

import SwiftUI

enum StatusBarStyleType: String {
    case theme
    case automatic
    case accent
    case custom
}

struct StatusBarStylePicker: View {
    @AppStorage("statusBarStyleType") var statusBarStyleType: StatusBarStyleType = .automatic

    var body: some View {
        List {
            Picker(selection: $statusBarStyleType, label: EmptyView()) {
                Text("Automatic tint")
                    .tag(StatusBarStyleType.automatic)
                Text("Follow theme")
                    .tag(StatusBarStyleType.theme)
                Text("App accent color")
                    .tag(StatusBarStyleType.accent)
                Text("Custom color")
                    .tag(StatusBarStyleType.custom)
            }
        }
        .pickerStyle(.inline)
        .listStyle(.insetGrouped)
        .navigationTitle("Status bar theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum StatusBarBehaviorType: String {
    case hide
    case partialHide
    case pin
}

struct StatusBarBehaviorPicker: View {
    @AppStorage("statusBarPinType") var statusBarPinType: StatusBarBehaviorType = .partialHide

    var body: some View {
        List {
            Picker(selection: $statusBarPinType, label: EmptyView()) {
                Text("Hidden")
                    .tag(StatusBarBehaviorType.hide)
                Text("Partially hidden")
                    .tag(StatusBarBehaviorType.partialHide)
                Text("Pinned")
                    .tag(StatusBarBehaviorType.pin)
            }
        }
        .pickerStyle(.inline)
        .listStyle(.insetGrouped)
        .navigationTitle("Status Bar Behavior")
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum DefaultSearchEngine: String {
    case google
    case brave
    case bing
    case duckduckgo
    case startpage
    case custom
}

struct BrowserSearchEnginePicker: View {
    @AppStorage("defaultSearchEngine") var defaultSearchEngine: DefaultSearchEngine = .google
    @AppStorage("customDefaultSearchEngine") var customSearchEngine = ""

    var body: some View {
        List {
            Picker(selection: $defaultSearchEngine, label: EmptyView()) {
                Text("Google")
                    .tag(DefaultSearchEngine.google)
                Text("Brave")
                    .tag(DefaultSearchEngine.brave)
                Text("Bing")
                    .tag(DefaultSearchEngine.bing)
                Text("DuckDuckGo")
                    .tag(DefaultSearchEngine.duckduckgo)
                Text("Startpage")
                    .tag(DefaultSearchEngine.startpage)
                Text("Custom")
                    .tag(DefaultSearchEngine.custom)
            }
            .pickerStyle(.inline)
            .listStyle(.insetGrouped)
            .navigationTitle("Default search engine")
            .navigationBarTitleDisplayMode(.inline)

            if defaultSearchEngine == .custom {
                Section(header: Text("Custom search engine")) {
                    TextField("https://domain.com/search?q=%s", text: $customSearchEngine)
                        .keyboardType(.URL)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                }
            }
        }
    }
}
