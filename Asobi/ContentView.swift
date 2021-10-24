//
//  ContentView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI
import SwiftUIX

struct ContentView: View {
    @StateObject var model: WebViewModel = WebViewModel()
    @AppStorage("navigationAccent") var navigationAccent: Color = .red

    var body: some View {
        ZStack {
            // Open cubari on launch
            WebView(webView: model.webView, errorDescription: $model.errorDescription, showError: $model.showError, showNavigation: $model.showNavigation, showProgress: $model.showProgress)
                .edgesIgnoringSafeArea(.bottom)
                .zIndex(0)
            
            // ProgressView for loading
            if model.showProgress {
                GroupBox {
                    VStack {
                        CircularProgressBar(model.webView.estimatedProgress)
                            .lineWidth(6)
                            .foregroundColor(navigationAccent)
                            .frame(width: 60, height: 60)
                        
                        Text("Loading...")
                            .font(.title2)
                    }
                }
                .zIndex(1)
            }
            
            VStack {
                Spacer()
                
                // Error description view
                if model.showError {
                    VStack {
                        GroupBox {
                            Text("Error: \(model.errorDescription!)")
                        }
                    }
                    .transition(AnyTransition.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            model.showError = false
                        }
                    }
                    .padding()
                }
                
                if model.showNavigation {
                    NavigationBarView()
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            .zIndex(2)
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
