//
//  StatusBarBehaviorPicker.swift
//  Asobi
//
//  Created by Brian Dashore on 4/7/22.
//

import SwiftUI

struct StatusBarStylePicker: View {
    @AppStorage("statusBarStyleType") var statusBarStyleType: StatusBarStyleType = .automatic

    var body: some View {
        List {
            ForEach(StatusBarStyleType.allCases, id: \.self) { style in
                Button {
                    statusBarStyleType = style
                } label: {
                    HStack {
                        Text(fetchPickerChoiceName(style))
                        Spacer()
                        if style == statusBarStyleType {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .accentColor(.primary)
            }
        }
        .listStyle(.insetGrouped)
        .inlinedList()
        .navigationTitle("Status Bar Style")
        .navigationBarTitleDisplayMode(.inline)
    }

    func fetchPickerChoiceName(_ style: StatusBarStyleType) -> String {
        switch style {
        case .automatic:
            return "Automatic tint"
        case .theme:
            return "Follow theme"
        case .accent:
            return "App accent color"
        case .custom:
            return "Custom color"
        }
    }
}

struct StatusBarBehaviorPicker: View {
    @AppStorage("statusBarPinType") var statusBarPinType: StatusBarBehaviorType = .partialHide

    var body: some View {
        List {
            ForEach(StatusBarBehaviorType.allCases, id: \.self) { behavior in
                Button {
                    statusBarPinType = behavior
                } label: {
                    HStack {
                        Text(fetchPickerChoiceName(behavior))
                        Spacer()
                        if behavior == statusBarPinType {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .accentColor(.primary)
            }
        }
        .listStyle(.insetGrouped)
        .inlinedList()
        .navigationTitle("Status Bar Behavior")
        .navigationBarTitleDisplayMode(.inline)
    }

    func fetchPickerChoiceName(_ behavior: StatusBarBehaviorType) -> String {
        switch behavior {
        case .hide:
            return "Hidden"
        case .partialHide:
            return "Partially hidden"
        case .pin:
            return "Pinned"
        }
    }
}

struct BrowserSearchEnginePicker: View {
    @AppStorage("defaultSearchEngine") var defaultSearchEngine: DefaultSearchEngine = .google
    @AppStorage("customDefaultSearchEngine") var customSearchEngine = ""

    var body: some View {
        List {
            ForEach(DefaultSearchEngine.allCases, id: \.self) { engine in
                Button {
                    defaultSearchEngine = engine
                } label: {
                    HStack {
                        Text(fetchPickerChoiceName(engine))
                        Spacer()
                        if engine == defaultSearchEngine {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .accentColor(.primary)
            }

            if defaultSearchEngine == .custom {
                Section("Custom search engine") {
                    TextField("https://domain.com/search?q=%s", text: $customSearchEngine)
                        .keyboardType(.URL)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                }
            }
        }
        .listStyle(.insetGrouped)
        .inlinedList()
        .navigationTitle("Default Search Engine")
        .navigationBarTitleDisplayMode(.inline)
    }

    func fetchPickerChoiceName(_ engine: DefaultSearchEngine) -> String {
        switch engine {
        case .google:
            return "Google"
        case .brave:
            return "Brave"
        case .bing:
            return "Bing"
        case .duckduckgo:
            return "DuckDuckGo"
        case .startpage:
            return "Startpage"
        case .custom:
            return "Custom"
        }
    }
}
