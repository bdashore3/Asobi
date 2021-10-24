//
//  NavigationBarView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/4/21.
//

import SwiftUI

struct NavigationBarView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @AppStorage("leftHandMode") var leftHandMode = false
    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    
    var body: some View { 
        VStack {
            // Sets button position depending on hand mode setting
            HStack {
                if leftHandMode {
                    if horizontalSizeClass == .regular {
                        Spacer()
                    }
                    ForwardBackButtonView()
                    Spacer()
                    SettingsButtonView()
                    Spacer()
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        RefreshButtonView()
                        Spacer()
                    }
                    LibraryButtonView()
                    Spacer()
                    HomeButtonView()
                    if horizontalSizeClass == .regular {
                        Spacer()
                    }
                } else {
                    if horizontalSizeClass == .regular {
                        Spacer()
                    }
                    HomeButtonView()
                    Spacer()
                    LibraryButtonView()
                    Spacer()
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        RefreshButtonView()
                        Spacer()
                    }
                    SettingsButtonView()
                    Spacer()
                    ForwardBackButtonView()
                    if horizontalSizeClass == .regular {
                        Spacer()
                    }
                }
            }
            .padding()
            .padding(.bottom, UIDevice.current.hasNotch ? 30 : 0)
            .background(colorScheme == .light ? Color.white : Color.black)
            .accentColor(navigationAccent)
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
