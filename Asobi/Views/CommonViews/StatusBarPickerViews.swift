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
        List {
            Picker(selection: $statusBarStyleType, label: EmptyView()) {
                Text("Follow theme")
                    .tag(StatusBarStyleType.theme)
                Text("Automatic tint")
                    .tag(StatusBarStyleType.automatic)
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
