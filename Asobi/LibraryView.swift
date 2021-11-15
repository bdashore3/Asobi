//
//  BookmarkView.swift
//  Asobi
//
//  Created by Brian Dashore on 10/15/21.
//

import SwiftUI
import CoreData

struct LibraryView: View {    
    @EnvironmentObject var navView: NavigationViewModel
    
    @State var currentUrl: String?
    
    @State private var dismissSelf = false
    @State private var tabSelect = 0
    @State private var showEditing = false
    @State private var currentBookmark: Bookmark?
    @State private var isCopiedButton = false
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Tabs", selection: $tabSelect) {
                    Text("Bookmarks").tag(0)
                    Text("History").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                Spacer()
                
                if tabSelect == 0 {
                    BookmarkView(currentBookmark: $currentBookmark, showEditing: $showEditing)
                } else {
                    HistoryView()
                }
                
                Spacer()
            }
            .background(
                navigationSwitchView
            )
            .navigationBarTitle(tabSelect == 0 ? "Bookmarks": "History", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if tabSelect == 0 {
                        // Showing bookmark view
                        Button("Add") {
                            showEditing.toggle()
                        }
                    } else {
                        // Showing history view
                        HistoryActionView()
                    }

                    Spacer()
                    
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        navView.currentSheet = nil
                    }
                    .keyboardShortcut(.cancelAction)
                }
                
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .environment(\.editMode, $editMode)
        }
    }

    @ViewBuilder
    var navigationSwitchView: some View {
        if tabSelect == 0 {
            NavigationLink("", destination: EditBookmarkView(bookmark: $currentBookmark), isActive: $showEditing)
        } else {
            NavigationLink("", destination: AboutView(), isActive: $showEditing)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(currentUrl: "")
    }
}
