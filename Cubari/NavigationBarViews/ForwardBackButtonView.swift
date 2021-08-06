//
//  ForwardBackView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct ForwardBackButtonView: View {
    @ObservedObject var model: WebViewModel
    
    var body: some View {
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
    }
}

#if DEBUG
struct ForwardBackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ForwardBackButtonView(model: WebViewModel())
    }
}
#endif
