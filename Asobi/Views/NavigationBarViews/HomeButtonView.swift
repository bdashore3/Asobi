//
//  HomeView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct HomeButtonView: View {
    @EnvironmentObject var webModel: WebViewModel

    var body: some View {
        Button(action: {
            webModel.goHome()
        }, label: {
            Image(systemName: "house")
                .padding(.horizontal, 4)
        })
    }
}

#if DEBUG
struct HomeButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HomeButtonView()
    }
}
#endif
