//
//  SettingsAppearanceView.swift
//  Asobi
//
//  Created by Brian Dashore on 4/9/22.
//

import SwiftUI

struct SettingsAppearanceView: View {
    @EnvironmentObject var webModel: WebViewModel

    @AppStorage("leftHandMode") var leftHandMode = false
    @AppStorage("useDarkTheme") var useDarkTheme = false

    @AppStorage("followSystemTheme") var followSystemTheme = true

    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    @AppStorage("statusBarStyleType") var statusBarStyleType: StatusBarStyleType = .automatic
    @AppStorage("statusBarAccent") var statusBarAccent: Color = .clear

    var body: some View {
        // MARK: Appearance settings

        // The combination of toggles and a ColorPicker cause keyboard shortcuts to stop working
        // Reported this bug to Apple
        Section(header: Text("Appearance")) {
            Toggle(isOn: $leftHandMode) {
                Text("Left handed mode")
            }

            Toggle(isOn: $useDarkTheme) {
                Text("Use dark theme")
            }
            .disabledAppearance(followSystemTheme)
            .disabled(followSystemTheme)

            Toggle(isOn: $followSystemTheme) {
                Text("Follow system theme")
            }

            ColorPicker("Accent color", selection: $navigationAccent, supportsOpacity: false)

            if UIDevice.current.deviceType != .mac {
                NavigationLink(
                    destination: StatusBarStylePicker(),
                    label: {
                        HStack {
                            Text("Status bar style")
                            Spacer()
                            Group {
                                switch statusBarStyleType {
                                case .theme:
                                    Text("Theme")
                                case .automatic:
                                    Text("Automatic")
                                case .custom:
                                    Text("Custom")
                                }
                            }
                            .foregroundColor(.gray)
                        }
                    }
                )
                .onChange(of: statusBarStyleType) { _ in
                    webModel.setStatusbarColor()
                }

                ColorPicker("Status bar color", selection: $statusBarAccent, supportsOpacity: true)
                    .onChange(of: statusBarAccent) { _ in
                        webModel.setStatusbarColor()
                    }
                    .disabledAppearance(statusBarStyleType != .custom)
                    .disabled(statusBarStyleType != .custom)
            }
        }
    }
}

struct SettingsAppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAppearanceView()
    }
}
