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

    @AppStorage("useUrlBar") var useUrlBar = false

    var body: some View {
        Button(action: {
            navModel.currentSheet = .library
        }, label: {
            Image(systemName: "book")
                .padding(.horizontal, 4)
        })
        .contextMenu {
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

            if webModel.findInPageEnabled {
                Button {
                    webModel.showFindInPage.toggle()
                } label: {
                    Text("Find in page")
                    Image(systemName: "magnifyingglass")
                }
            }

            if useUrlBar {
                Button {
                    webModel.showUrlBar.toggle()
                } label: {
                    Text("Show URL bar")
                    Image(systemName: "link")
                }
            }

            if UIDevice.current.deviceType == .phone {
                Button {
                    webModel.webView.reload()
                } label: {
                    Text("Refresh page")
                    Image(systemName: "arrow.clockwise")
                }
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
