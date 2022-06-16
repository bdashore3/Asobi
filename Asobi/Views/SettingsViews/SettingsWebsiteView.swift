//
//  SettingsWebsiteView.swift
//  Asobi
//
//  Created by Brian Dashore on 4/9/22.
//

import SwiftUI

struct SettingsWebsiteView: View {
    @EnvironmentObject var webModel: WebViewModel

    @AppStorage("changeUserAgent") var changeUserAgent = false
    @AppStorage("loadLastHistory") var loadLastHistory = false
    @AppStorage("useUrlBar") var useUrlBar = false

    @AppStorage("defaultUrl") var defaultUrl = ""

    @State private var showUrlChangeAlert: Bool = false
    @State private var showUrlBarAlert: Bool = false

    var body: some View {
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
                footer: VStack(alignment: .leading, spacing: 8) {
                    Text("Sets the default URL when the app is launched. Https will be automatically added if you don't provide it.")
                    Text("The load most recent URL option loads the last URL from history on app launch.")
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
            .clearButtonMode(.whileEditing)
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
            .disabledAppearance(loadLastHistory)

            Toggle(isOn: $loadLastHistory) {
                Text("Load most recent URL")
            }
        }

        Section(header: Text("URL bar")) {
            Toggle(isOn: $useUrlBar) {
                Text("Enable URL bar")
            }
            .onChange(of: useUrlBar) { changed in
                if changed {
                    showUrlBarAlert.toggle()
                }
            }
            .alert(isPresented: $showUrlBarAlert) {
                Alert(
                    title: Text("URL bar enabled"),
                    message: Text("The navigation bar should have a link icon now. \n\n" +
                        "The homepage button is located in the library context menu. \n\n" +
                        "If this interferes with browsing, please disable the setting."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct SettingsWebsiteView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsWebsiteView()
    }
}
