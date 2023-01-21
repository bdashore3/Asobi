//
//  FindInPageButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/22.
//

import SwiftUI

struct FindInPageButtonView: View {
    @EnvironmentObject var navModel: NavigationViewModel

    var body: some View {
        Button(action: {
            navModel.currentPillView = .findInPage
        }, label: {
            Image(systemName: "text.magnifyingglass")
                .padding(.horizontal, 4)
        })
        .keyboardShortcut("f")
    }
}

struct FindInPageButtonView_Previews: PreviewProvider {
    static var previews: some View {
        FindInPageButtonView()
    }
}
