//
//  SettingsView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var model: WebViewModel
    @Binding var showView: Bool

    // All settings here
    @AppStorage("leftHandMode") var leftHandMode = false
    @AppStorage("persistNavigation") var persistNavigation = false
    @AppStorage("blockAds") var blockAds = false
    @AppStorage("changeUserAgent") var changeUserAgent = false
    @AppStorage("defaultUrl") var defaultUrl = ""
    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    
    @State private var showAdblockAlert: Bool = false
    @State private var showUrlChangeAlert: Bool = false
    
    // Core settings. All prefs saved in UserDefaults
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Navigation Bar"),
                        footer: Text("Some of these settings will cause the menu to close. This is because the parent navigation bar is refreshing.")) {
                    Toggle(isOn: $leftHandMode) {
                        Text("Left handed mode")
                    }
                    Toggle(isOn: $persistNavigation) {
                        Text("Lock navigation bar")
                    }
                    ColorPicker("Navigation bar accent color", selection: $navigationAccent, supportsOpacity: false)
                }
                Section(header: Text("Blockers"),
                        footer: Text("Only enable adblock if you need it! This will cause app launching to become somewhat slower.")) {
                        Toggle(isOn: $blockAds) {
                            Text("Block ads")
                        }
                        .onChange(of: blockAds) { changed in
                            if changed {
                                model.enableBlocker()
                            } else {
                                model.disableBlocker()
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
                        model.setUserAgent(changeUserAgent: changed)
                        model.webView.reload()
                    }
                }
                Section(header: Text("Default URL"),
                        footer: Text("Sets the default URL when the app is launched. Https will be automatically added if you don't provide it. If the page doesn't refresh automatically or is white, check the URL format or refresh the page manually.")) {
                    
                    // Auto capitalization modifier will be deprecated at some point
                    TextField("https://...", text: $defaultUrl, onEditingChanged: { begin in
                        if !begin {
                            showUrlChangeAlert.toggle()
                            model.loadUrl(goHome: true)
                        }
                    })
                    .textCase(.lowercase)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .alert(isPresented: $showUrlChangeAlert) {
                        Alert(
                            title: Text("The default URL was changed"),
                            message: Text("Your page should refresh to the new URL when you exit settings"),
                            dismissButton: .cancel(Text("OK!"))
                        )
                    }
                }
            }
            .navigationBarTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        showView.toggle()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showView: .constant(true))
    }
}
#endif
