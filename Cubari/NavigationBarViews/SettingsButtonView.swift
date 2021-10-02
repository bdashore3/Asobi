//
//  SettingsButtonView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct SettingsButtonView: View {
    @ObservedObject var model: WebViewModel
    @State private var showSettings = false
    
    var body: some View {
        Button(action: {
            showSettings.toggle()
        }, label: {
            Image(systemName: "gear")
        })
        .sheet(isPresented: $showSettings) {
            SettingsView(model: model, showView: $showSettings)
        }
    }
}

#if DEBUG
struct SettingsButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButtonView(model: WebViewModel())
    }
}
#endif
