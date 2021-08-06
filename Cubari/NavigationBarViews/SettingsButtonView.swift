//
//  SettingsButtonView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI
import PartialSheet

struct SettingsButtonView: View {
    @EnvironmentObject var partialSheet: PartialSheetManager

    @State private var showSettings = false
    
    var body: some View {
        Button(action: {
            showSettings.toggle()
        }, label: {
            Image(systemName: "gear")
        })
        .partialSheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct SettingsButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButtonView()
            .addPartialSheet()
            .environmentObject(PartialSheetManager())
    }
}
