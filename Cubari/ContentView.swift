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

            // Navigation bar view
            if model.showNavigation {
                VStack {
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            model.goBack()
                        }, label: {
                            Image(systemName: "arrow.left")
                        })
                        .disabled(!model.canGoBack)
                        .foregroundColor(Color.red)
                        
                        Spacer()
                        
                        Button(action: {
                            model.goForward()
                        }, label: {
                            Image(systemName: "arrow.right")
                        })
                        .disabled(!model.canGoForward)
                        .foregroundColor(Color.red)
                        
                        Spacer()
                        
                        Button(action: {
                            model.goHome()
                        }, label: {
                            Image(systemName: "house")
                        })
                        .foregroundColor(Color.red)

                        
                        Spacer()
                        
                        Button(action: {
                            print("About button tapped")
                        }, label: {
                            Image(systemName: "info.circle")
                        })
                        .foregroundColor(Color.red)

                    }
                    .padding()
                    .background(Color.black)
                }
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
