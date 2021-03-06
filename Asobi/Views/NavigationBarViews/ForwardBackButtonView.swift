//
//  ForwardBackView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct ForwardBackButtonView: View {
    @EnvironmentObject var webModel: WebViewModel

    var body: some View {
        Button(action: {
            webModel.goBack()
        }, label: {
            Image(systemName: "arrow.left")
                .padding(4)
        })
        .disabled(!webModel.canGoBack)

        Spacer()

        Button(action: {
            webModel.goForward()
        }, label: {
            Image(systemName: "arrow.right")
                .padding(.horizontal, 4)
        })
        .disabled(!webModel.canGoForward)
    }
}

#if DEBUG
struct ForwardBackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ForwardBackButtonView()
    }
}
#endif
