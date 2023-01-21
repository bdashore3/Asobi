//
//  UrlBarButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 6/16/22.
//

import SwiftUI

struct UrlBarButtonView: View {
    @EnvironmentObject var navModel: NavigationViewModel

    var body: some View {
        Button(action: {
            navModel.currentPillView = .urlBar
        }, label: {
            Image(systemName: "link")
                .padding(.horizontal, 4)
        })
    }
}

struct UrlBarButtonView_Previews: PreviewProvider {
    static var previews: some View {
        UrlBarButtonView()
    }
}
