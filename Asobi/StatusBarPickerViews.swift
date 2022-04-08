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
    case custom
}

struct StatusBarStylePicker: View {
    @AppStorage("statusBarStyleType") var statusBarStyleType: StatusBarStyleType = .automatic

    var body: some View {
        Form {
            Picker("Status bar theme", selection: $statusBarStyleType) {
                Text("Follow theme")
                    .tag(StatusBarStyleType.theme)
                Text("Automatic tint")
                    .tag(StatusBarStyleType.automatic)
                Text("Custom color")
                    .tag(StatusBarStyleType.custom)
            }
        }
        .labelsHidden()
        .pickerStyle(.inline)
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
        Form {
            Picker("Status bar type", selection: $statusBarPinType) {
                Text("Hidden")
                    .tag(StatusBarBehaviorType.hide)
                Text("Partially hidden")
                    .tag(StatusBarBehaviorType.partialHide)
                Text("Pinned")
                    .tag(StatusBarBehaviorType.pin)
            }
        }
        .labelsHidden()
        .pickerStyle(.inline)
        .navigationTitle("Status Bar Behavior")
        .navigationBarTitleDisplayMode(.inline)
    }
}
