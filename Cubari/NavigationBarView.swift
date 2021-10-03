//
//  NavigationBarView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/4/21.
//

import SwiftUI

struct NavigationBarView: View {
    @AppStorage("leftHandMode") var leftHandMode = false
    @State private var showAbout = false
    
    var body: some View {
        VStack {
            Spacer()

            // Sets button position depending on hand mode setting
            HStack {
                if leftHandMode {
                    ForwardBackButtonView()
                    Spacer()
                    SettingsButtonView()
                    Spacer()
                    HomeButtonView()
                    Spacer()
                    AboutButtonView()
                } else {
                    AboutButtonView()
                    Spacer()
                    HomeButtonView()
                    Spacer()
                    SettingsButtonView()
                    Spacer()
                    ForwardBackButtonView()
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
        NavigationBarView()
    }
}
#endif
