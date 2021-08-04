//
//  NavigationBarView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/4/21.
//

import SwiftUI

struct NavigationBarView: View {
    @ObservedObject var model: WebViewModel
    
    var body: some View {
        VStack {
            Spacer()

            HStack {
                Button(action: {
                    model.goBack()
                }, label: {
                    Image(systemName: "arrow.left")
                })
                .disabled(!model.canGoBack)
                
                Spacer()
                
                Button(action: {
                    model.goForward()
                }, label: {
                    Image(systemName: "arrow.right")
                })
                .disabled(!model.canGoForward)
                
                Spacer()
                
                Button(action: {
                    model.goHome()
                }, label: {
                    Image(systemName: "house")
                })
                
                Spacer()
                
                Button(action: {
                    print("About button tapped")
                }, label: {
                    Image(systemName: "info.circle")
                })
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
