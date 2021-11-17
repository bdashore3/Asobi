//
//  SettingsButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct SettingsButtonView: View {
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    var body: some View {
        Button(action: {
            navModel.currentSheet = .settings
        }, label: {
            Image(systemName: "gear")
        })
    }
}

#if DEBUG
struct SettingsButtonView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButtonView()
    }
}
#endif
