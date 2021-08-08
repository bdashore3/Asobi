//
//  SettingsView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showView: Bool
    
    // All settings here
    @AppStorage("leftHandMode") var leftHandMode = false
    @AppStorage("persistNavigation") var persistNavigation = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Navigation Bar"), footer: Text("Some of these settings will cause the menu to close. This is because the parent navigation bar is refreshing.")) {
                    Toggle(isOn: $leftHandMode) {
                        Text("Left handed mode")
                    }
                    Toggle(isOn: $persistNavigation) {
                        Text("Lock navigation bar")
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
