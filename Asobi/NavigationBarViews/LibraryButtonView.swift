//
//  AboutButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct LibraryButtonView: View {
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    var body: some View {
        Button(action: {
            navModel.currentSheet = .library
        }, label: {
            Image(systemName: "book")
        })
        .contextMenu() {
            Button {
                UIPasteboard.general.string = webModel.webView.url?.absoluteString
            } label: {
                Text("Copy current URL")
                Image(systemName: "doc.on.doc")
            }

            Button {
                navModel.currentSheet = .bookmarkEditing
            } label: {
                Text("Add bookmark")
                Image(systemName: "plus.circle")
            }
        }
    }
}

#if DEBUG
struct LibraryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryButtonView()
    }
}
#endif
