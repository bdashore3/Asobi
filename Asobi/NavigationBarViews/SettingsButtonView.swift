//
//  SettingsButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct SettingsButtonView: View {
    @EnvironmentObject var model: WebViewModel
    @State private var showSettings = false
    
    var body: some View {
        Button(action: {
            showSettings.toggle()
        }, label: {
            Image(systemName: "gear")
        })
        .sheet(isPresented: $showSettings) {
            SettingsView(showView: $showSettings)
        }
    }
}

#if DEBUG
struct SettingsButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButtonView()
    }
}
#endif
