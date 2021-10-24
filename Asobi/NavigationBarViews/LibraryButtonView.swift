//
//  AboutButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI
import SwiftUIX

enum LibraryViewType: Identifiable {
    var id: Int {
        self.hashValue
    }
    
    case normal
    case editing
}

struct LibraryButtonView: View {
    @EnvironmentObject var model: WebViewModel
    @State var showBookmarks: Bool = false
    @State var libraryViewType: LibraryViewType?
    
    var body: some View {
        Button(action: {
            libraryViewType = .normal
            showBookmarks.toggle()
        }, label: {
            Image(systemName: "book")
        })
        .contextMenu() {
            Button {
                UIPasteboard.general.string = model.webView.url?.absoluteString
            } label: {
                Text("Copy current URL")
                Image(systemName: "doc.on.doc")
            }
            
            Button {
                libraryViewType = .editing
                showBookmarks.toggle()
            } label: {
                Text("Add bookmark")
                Image(systemName: "plus.circle")
            }
        }
        .sheet(item: $libraryViewType) { item in
            if item == .editing {
                EditBookmarkView(bookmark: .constant(nil))
            } else {
                LibraryView(currentUrl: model.webView.url?.absoluteString)
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
