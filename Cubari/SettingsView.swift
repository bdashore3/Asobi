//
//  SettingsView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: WebViewModel
    @Binding var showView: Bool

    // All settings here
    @AppStorage("leftHandMode") var leftHandMode = false
    @AppStorage("persistNavigation") var persistNavigation = false
    @AppStorage("blockAds") var blockAds = false
    
    @State private var showAdblockAlert: Bool = false
    
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
                }
                Section(header: Text("Blockers"),
                        footer: Text("Only enable adblock if you need it! This will cause app launching to become somewhat slower.")) {
                        Toggle(isOn: $blockAds) {
                            Text("Block ads")
                        }
                        .onChange(of: blockAds) { _ in
                            if blockAds {
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
        SettingsView(model: WebViewModel(), showView: .constant(true))
    }
}
#endif
