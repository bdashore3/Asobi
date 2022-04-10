//
//  FindInPageButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/22.
//

import SwiftUI

struct FindInPageButtonView: View {
    @EnvironmentObject var webModel: WebViewModel

    var body: some View {
        Button(action: {
            webModel.showFindInPage.toggle()
        }, label: {
            Image(systemName: "magnifyingglass")
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
