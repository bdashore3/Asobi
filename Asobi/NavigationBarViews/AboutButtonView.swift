//
//  AboutButtonView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct AboutButtonView: View {
    @EnvironmentObject var model: WebViewModel
    @State var showBookmarks: Bool = false
    @State var showBookmarkAdd: Bool = false
    
    var body: some View {
        Button(action: {
            showBookmarks.toggle()
        }, label: {
            Image(systemName: "book")
        })
        .contextMenu() {
            Button {
                showBookmarkAdd.toggle()
            } label: {
                Text("Add bookmark")
                Image(systemName: "plus.circle")
            }
        }
        .sheet(isPresented: $showBookmarkAdd) {
            EditBookmarkView()
        }
        .sheet(isPresented: $showBookmarks) {
            BookmarkView()
        }
    }
}

#if DEBUG
struct AboutButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AboutButtonView()
    }
}
#endif
