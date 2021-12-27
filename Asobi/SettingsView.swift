//
//  SettingsView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    // All settings here
    @AppStorage("leftHandMode") var leftHandMode = false
    @AppStorage("persistNavigation") var persistNavigation = false
    @AppStorage("blockAds") var blockAds = false
    @AppStorage("changeUserAgent") var changeUserAgent = false
    @AppStorage("defaultUrl") var defaultUrl = ""
    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("incognitoMode") var incognitoMode = false
    @AppStorage("followSystemTheme") var followSystemTheme = true
    @AppStorage("useDarkTheme") var useDarkTheme = false

    @State private var showAdblockAlert: Bool = false
    @State private var showUrlChangeAlert: Bool = false

    // Core settings. All prefs saved in UserDefaults
    var body: some View {
        NavigationView {
            Form {
                // The combination of toggles and a ColorPicker cause keyboard shortcuts to stop working
                // Reported this bug to Apple
                Section(header: Text("Appearance"),
                        footer: Text("Following the system theme will close and reopen the settings menu to refresh any color changes")) {
                    Toggle(isOn: $leftHandMode) {
                        Text("Left handed mode")
                    }

                    Toggle(isOn: $persistNavigation) {
                        Text("Lock navigation bar")
                    }

                    Toggle(isOn: $autoHideNavigation) {
                        Text("Auto hide navigation bar")
                    }

                    Toggle(isOn: $useDarkTheme) {
                        Text("Use dark theme")
                            .foregroundColor(followSystemTheme ? .gray : (useDarkTheme ? .white : .black))
                    }
                    .disabled(followSystemTheme)
                    
                    // Make this toggle refresh the settings view to apply the right color
                    Toggle(isOn: $followSystemTheme) {
                        Text("Follow system theme")
                    }

                    ColorPicker("Accent color", selection: $navigationAccent, supportsOpacity: false)
                }
                Section(header: Text("Privacy"),
                        footer: Text("Only enable adblock if you need it! This will cause app launching to become somewhat slower.")) {
                        Toggle(isOn: $incognitoMode) {
                            Text("Incognito mode")
                        }

                        Toggle(isOn: $blockAds) {
                            Text("Block ads")
                        }
                        .onChange(of: blockAds) { changed in
                            Task {
                                if changed {
                                    await webModel.enableBlocker()
                                } else {
                                    webModel.disableBlocker()
                                }
                            }
                            
                            showAdblockAlert.toggle()
                        }
                        .alert(isPresented: $showAdblockAlert) {
                            Alert(
                                title: Text(blockAds ? "Adblock enabled" : "Adblock disabled"),
                                message: Text("The page will refresh when you exit settings"),
                                dismissButton: .cancel(Text("OK!"))
                            )
                        }
                }
                Section(header: Text("Website settings")) {
                    Toggle(isOn: $changeUserAgent) {
                        Text("Request \(UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? "mobile" : "desktop") website")
                    }
                    .onChange(of: changeUserAgent) { changed in
                        webModel.setUserAgent(changeUserAgent: changed)
                        webModel.webView.reload()
                    }
                }
                Section(header: Text("Default URL"),
                        footer:
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sets the default URL when the app is launched. Https will be automatically added if you don't provide it.")
                                Text("MacCatalyst users have to hit enter or return in the textbox for the URL change to appear.")
                                Text("If the loading animation keeps going, make sure your URL is correct!")
                            }
                ) {
                    // Auto capitalization modifier will be deprecated at some point
                    TextField("https://...", text: $defaultUrl, onEditingChanged: { begin in
                        if !begin && UIDevice.current.deviceType != .mac {
                            showUrlChangeAlert.toggle()
                            webModel.loadUrl()
                        }
                    }, onCommit: {
                        if UIDevice.current.deviceType == .mac {
                            showUrlChangeAlert.toggle()
                            webModel.loadUrl()
                        }
                    })
                    .textCase(.lowercase)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .alert(isPresented: $showUrlChangeAlert) {
                        Alert(
                            title: Text("The default URL was changed"),
                            message: Text("Your page should have refreshed to the new URL"),
                            dismissButton: .cancel(Text("OK!"))
                        )
                    }
                }
                if UIDevice.current.deviceType == .phone || UIDevice.current.deviceType == .pad {
                    Section(header: Text("App Icon")) {
                        AppIconPickerView()
                    }
                }
                Section {
                    NavigationLink(destination: AboutView()) {
                        Text("About")
                    }
                }
            }
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
