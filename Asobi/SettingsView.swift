//
//  SettingsView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel
    @EnvironmentObject var downloadManager: DownloadManager

    // Default false settings here
    @AppStorage("leftHandMode") var leftHandMode = false
    @AppStorage("persistNavigation") var persistNavigation = false
    @AppStorage("blockAds") var blockAds = false
    @AppStorage("changeUserAgent") var changeUserAgent = false
    @AppStorage("autoHideNavigation") var autoHideNavigation = false
    @AppStorage("incognitoMode") var incognitoMode = false
    @AppStorage("useDarkTheme") var useDarkTheme = false

    // Default true settings here
    @AppStorage("followSystemTheme") var followSystemTheme = true
    @AppStorage("allowSwipeNavGestures") var allowSwipeNavGestures = true
    @AppStorage("overwriteDownloadedFiles") var overwriteDownloadedFiles = true

    // Other setting types here
    @AppStorage("defaultUrl") var defaultUrl = ""
    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    @AppStorage("defaultDownloadDirectory") var defaultDownloadDirectory = ""

    @State private var showAdblockAlert: Bool = false
    @State private var showUrlChangeAlert: Bool = false
    @State private var showDownloadResetAlert: Bool = false
    @State private var showFolderPicker: Bool = false
    @State private var backgroundColor: Color = .clear

    // Core settings. All prefs saved in UserDefaults
    var body: some View {
        NavigationView {
            Form {
                // The combination of toggles and a ColorPicker cause keyboard shortcuts to stop working
                // Reported this bug to Apple
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $leftHandMode) {
                        Text("Left handed mode")
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
                Section(header: Text("Behavior"),
                        footer: Text("The allow browser swipe gestures toggle enables/disables the webview's navigation gestures")) {
                    Toggle(isOn: $persistNavigation) {
                        Text("Lock navigation bar")
                    }

                    Toggle(isOn: $autoHideNavigation) {
                        Text("Auto hide navigation bar")
                    }

                    Toggle(isOn: $allowSwipeNavGestures) {
                        Text("Allow browser swipe gestures")
                    }
                    .onChange(of: allowSwipeNavGestures) { changed in
                        if changed {
                            webModel.webView.allowsBackForwardNavigationGestures = true
                        } else {
                            webModel.webView.allowsBackForwardNavigationGestures = false
                        }
                    }
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
                        if changed {
                            Task {
                                await webModel.enableBlocker()
                            }
                        } else {
                            webModel.disableBlocker()
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
                if UIDevice.current.deviceType != .mac {
                    Section(header: Text("Download options")) {
                        HStack {
                            Text("Downloads")

                            Spacer()

                            Group {
                                Text(defaultDownloadDirectory.isEmpty ? "Downloads" : defaultDownloadDirectory)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.gray)
                        }
                        .lineLimit(0)
                        .background(backgroundColor)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                navModel.currentSheet = nil

                                try await Task.sleep(seconds: 0.5)

                                downloadManager.showDefaultDirectoryPicker.toggle()
                            }
                        }

                        Toggle(isOn: $overwriteDownloadedFiles) {
                            Text("Overwrite files on download")
                        }

                        Button("Reset Download Directory") {
                            defaultDownloadDirectory = ""

                            showDownloadResetAlert.toggle()
                        }
                        .foregroundColor(.red)
                        .alert(isPresented: $showDownloadResetAlert) {
                            Alert(
                                title: Text("Success"),
                                message: Text("The downloads directory has been reset to Asobi's documents folder"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
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
                        }) {
                    // Auto capitalization modifier will be deprecated at some point
                    TextField("https://...", text: $defaultUrl, onEditingChanged: { begin in
                        if !begin, UIDevice.current.deviceType != .mac {
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
                if UIDevice.current.deviceType != .mac {
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
