//
//  ContentView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var model = WebViewModel()
    
    var body: some View {
        ZStack {
            // Open cubari on launch
            WebView(webView: model.webView, showNavigation: $model.showNavigation)
                .zIndex(0)

            // Navigation bar view
            if model.showNavigation  {
                NavigationBarView(model: model)
                    .zIndex(1)
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
