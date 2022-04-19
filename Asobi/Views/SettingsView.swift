//
//  SettingsView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var navModel: NavigationViewModel

    @AppStorage("useDarkTheme") var useDarkTheme = false
    @AppStorage("followSystemTheme") var followSystemTheme = true
    @AppStorage("navigationAccent") var navigationAccent: Color = .red

    // Core settings. All prefs saved in UserDefaults
    var body: some View {
        NavigationView {
            Form {
                SettingsAppearanceView()
                SettingsBehaviorView()
                SettingsPrivacyView()
                SettingsDownloadsView()
                SettingsWebsiteView()

                // MARK: App icon picker (iDevices only)

                if UIDevice.current.deviceType != .mac {
                    Section(header: Text("App Icon")) {
                        AppIconPickerView()
                    }
                }

                // MARK: Credentials and problems

                Section {
                    ListRowExternalLinkView(text: "Guides", link: "https://github.com/bdashore3/Asobi/wiki")

                    ListRowExternalLinkView(text: "Report issues", link: "https://github.com/bdashore3/Asobi/issues")

                    NavigationLink(destination: AboutView()) {
                        Text("About")
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: navigationAccent))
            .navigationBarTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        navModel.currentSheet = nil
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
        }
        .blur(radius: navModel.blurRadius)
        .applyTheme(followSystemTheme ? nil : (useDarkTheme ? "dark" : "light"))
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
