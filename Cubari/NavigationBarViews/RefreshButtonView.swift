//
//  RefreshButtonView.swift
//  Cubari
//
//  Created by Brian Dashore on 10/6/21.
//

import SwiftUI

struct RefreshButtonView: View {
    @EnvironmentObject var model: WebViewModel
    
    var body: some View {
        Button(action: {
            model.showError = false
            model.webView.reload()
            model.showProgress = true
        }, label: {
            Image(systemName: "arrow.clockwise")
        })
        .keyboardShortcut("r")
    }
}

struct RefreshButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshButtonView()
    }
}
