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

    @AppStorage("defaultUrl") var defaultUrl = ""

    @State private var showUrlChangeAlert: Bool = false

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
    }
}

struct SettingsWebsiteView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsWebsiteView()
    }
}
