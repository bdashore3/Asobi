//
//  NavigationBarView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/4/21.
//

import SwiftUI

struct NavigationBarView: View {
    @ObservedObject var model: WebViewModel
    @AppStorage("leftHandMode") var leftHandMode = false
    @State private var showAbout = false
    
    var body: some View {
        VStack {
            Spacer()

            HStack {
                if leftHandMode {
                    ForwardBackButtonView(model: model)
                    Spacer()
                    SettingsButtonView()
                    Spacer()
                    HomeButtonView(model: model)
                    Spacer()
                    AboutButtonView()
                } else {
                    AboutButtonView()
                    Spacer()
                    HomeButtonView(model: model)
                    Spacer()
                    SettingsButtonView()
                    Spacer()
                    ForwardBackButtonView(model: model)
                }
            }
            .padding()
            .background(Color.black)
            .accentColor(.red)
        }
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
    }
}

#if DEBUG
struct NavigationBarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarView(model: WebViewModel())
    }
}
#endif
