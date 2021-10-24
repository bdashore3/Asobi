//
//  HomeView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct HomeButtonView: View {
    @EnvironmentObject var model: WebViewModel
    
    var body: some View {
        Button(action: {
            model.goHome()
        }, label: {
            Image(systemName: "house")
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
