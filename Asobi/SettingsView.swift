//
//  SettingsView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import LocalAuthentication
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
    @AppStorage("forceSecurityCredentials") var forceSecurityCredentials = false
    @AppStorage("blurInRecents") var blurInRecents = false
    @AppStorage("forceFullScreen") var forceFullScreen = false
    @AppStorage("clearCacheAtStart") var clearCacheAtStart = false

    // Default true settings here
    @AppStorage("followSystemTheme") var followSystemTheme = true
    @AppStorage("allowSwipeNavGestures") var allowSwipeNavGestures = true
    @AppStorage("overwriteDownloadedFiles") var overwriteDownloadedFiles = true

    // Other setting types here
    @AppStorage("defaultUrl") var defaultUrl = ""
    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    @AppStorage("defaultDownloadDirectory") var defaultDownloadDirectory = ""
    @AppStorage("downloadDirectoryBookmark") var downloadDirectoryBookmark: Data?

    @State private var showAdblockAlert: Bool = false
    @State private var showUrlChangeAlert: Bool = false
    @State private var showForceFullScreenAlert: Bool = false
    @State private var showDownloadResetAlert: Bool = false
    @State private var showFolderPicker: Bool = false
    @State private var backgroundColor: Color = .clear
    @State private var alreadyAuthenticated: Bool = false

    // Core settings. All prefs saved in UserDefaults
    var body: some View {
        NavigationView {
            Form {
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
                    .disabled(followSystemTheme)

                    Toggle(isOn: $followSystemTheme) {
                        Text("Follow system theme")
                    }

                    ColorPicker("Accent color", selection: $navigationAccent, supportsOpacity: false)
                }

                // MARK: Browser behavior settings

                Section(header: Text("Behavior"),
                        footer: Text(
                            "The clear cache option clears browser cache on app launch. \nThe allow browser swipe gestures option toggles the webview's navigation gestures."
                        )) {
                    Toggle(isOn: $persistNavigation) {
                        Text("Lock navigation bar")
                    }
                    .onChange(of: persistNavigation) { changed in
                        if changed {
                            autoHideNavigation = false
                        }

                        navModel.showNavigationBar = true
                    }

                    Toggle(isOn: $autoHideNavigation) {
                        Text("Auto hide navigation bar")
                    }
                    .disabled(persistNavigation)

                    Toggle(isOn: $forceFullScreen) {
                        Text("Force fullscreen video")
                    }
                    .onChange(of: forceFullScreen) { _ in
                        showForceFullScreenAlert.toggle()
                    }
                    .alert(isPresented: $showForceFullScreenAlert) {
                        Alert(
                            title: Text(forceFullScreen ? "Fullscreen enabled" : "Fullscreen disabled"),
                            message: Text("Changing this setting requires an app restart"),
                            dismissButton: .cancel(Text("OK!"))
                        )
                    }

                    Toggle(isOn: $clearCacheAtStart) {
                        Text("Clear cache on app launch")
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

                // MARK: Privacy settings

                Section(header: Text("Privacy and security"),
                        footer: Text("Only enable adblock if you need it! This will cause app launching to become somewhat slower")) {
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

                    if UIDevice.current.deviceType != .mac {
                        Toggle(isOn: $blurInRecents) {
                            Text("Blur in recents menu")
                        }
                    }

                    if navModel.authenticationPresent() {
                        Toggle(isOn: $forceSecurityCredentials) {
                            Text("Force authentication")
                        }
                        .onChange(of: forceSecurityCredentials) { changed in
                            // To prevent looping of authentication prompts
                            if alreadyAuthenticated {
                                alreadyAuthenticated = false
                                return
                            }

                            let context = LAContext()

                            Task {
                                do {
                                    let result = try await context.evaluatePolicy(
                                        .deviceOwnerAuthentication,
                                        localizedReason: "Authentication is required to change this setting"
                                    )

                                    forceSecurityCredentials = result ? changed : !changed
                                } catch {
                                    // Ignore and log the error
                                    debugPrint("Settings authentication error!: \(error)")

                                    await MainActor.run {
                                        alreadyAuthenticated = true

                                        forceSecurityCredentials = !changed
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: Downloads directory (for iDevices)

                if UIDevice.current.deviceType != .mac {
                    Section(header: Text("Download options"),
                            footer: Text("If a downloaded file has the same name as a local file, the local file will be overwritten if the toggle is on.")) {
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

                        Button("Reset download directory") {
                            downloadDirectoryBookmark = nil
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

                // MARK: Website settings (settings that can alter website content)

                Section(header: Text("Website settings")) {
                    Toggle(isOn: $changeUserAgent) {
                        Text("Request \(UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac ? "mobile" : "desktop") website")
                    }
                    .onChange(of: changeUserAgent) { changed in
                        webModel.setUserAgent(changeUserAgent: changed)
                        webModel.webView.reload()
                    }
                }

                // MARK: Default URL setting

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

                // MARK: App icon picker (iDevices only)

                if UIDevice.current.deviceType != .mac {
                    Section(header: Text("App Icon")) {
                        AppIconPickerView()
                    }
                }

                // MARK: Credentials and problems

                Section {
                    ListRowExternalLinkView(text: "Report issues", link: "https://github.com/bdashore3/Asobi/issues")

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
