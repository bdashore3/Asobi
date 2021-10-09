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
            WebView(webView: model.webView, errorDescription: $model.errorDescription, showError: $model.showError, showNavigation: $model.showNavigation, showProgress: $model.showProgress)
                .zIndex(0)
            
            // ProgressView for loading
            if model.showProgress {
                GroupBox {
                    VStack {
                        Text("Loading...")
                        ProgressView()
                            .scaleEffect(2.0, anchor: .center)
                            .padding()
                    }
                }
                .zIndex(1)
            }
            
            // Error description view
            if model.showError {
                GroupBox {
                    VStack {
                        Text("Error: \(model.errorDescription!)")
                        Text("Make sure the default URL in settings is correct!")
                    }
                }
                .zIndex(2)
            }
            
            // Navigation bar view
            if model.showNavigation {
                NavigationBarView()
                    .zIndex(3)
            }
        }
        .environmentObject(model)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
