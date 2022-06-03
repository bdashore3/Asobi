//
//  SettingsSyncView.swift
//  Asobi
//
//  Created by Brian Dashore on 5/14/22.
//

import SwiftUI

struct SettingsSyncView: View {
    @AppStorage("iCloudEnabled") var iCloudEnabled = false

    @State private var showiCloudAlert = false

    var body: some View {
        Section(header: Text("Sync options"), footer: Text("iCloud syncing is currently experimental! You may have duplicates in history or bookmarks")) {
            Toggle(isOn: $iCloudEnabled) {
                Text("iCloud sync")
            }
            .onChange(of: iCloudEnabled) { _ in
                showiCloudAlert.toggle()
            }
            .alert(isPresented: $showiCloudAlert) {
                Alert(
                    title: Text(iCloudEnabled ? "Syncing enabled" : "Syncing disabled"),
                    message: Text("Changing this setting requires an app restart"),
                    dismissButton: .cancel(Text("OK"))
                )
            }
        }
    }
}

struct SettingsSyncView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSyncView()
    }
}
