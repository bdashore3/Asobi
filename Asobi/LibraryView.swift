//
//  BookmarkView.swift
//  Asobi
//
//  Created by Brian Dashore on 10/15/21.
//

import CoreData
import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @AppStorage("useDarkTheme") var useDarkTheme = false
    @AppStorage("followSystemTheme") var followSystemTheme = true

    @State var currentUrl: String = "No URL found"

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
                    Text("Actions").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()

                Spacer()

                switch tabSelect {
                case 0:
                    BookmarkView(currentBookmark: $currentBookmark, showEditing: $showEditing)
                case 1:
                    LibraryActionsView(currentUrl: $currentUrl)
                case 2:
                    HistoryView()
                default:
                    EmptyView()
                }

                Spacer()
            }
            .background(
                navigationSwitchView
            )
            .navigationBarTitle(getNavigationBarTitle(tabSelect), displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if tabSelect == 0 {
                        // Showing bookmark view
                        Button("Add") {
                            showEditing.toggle()
                        }
                    } else if #available(iOS 15, *), tabSelect == 2 {
                        // Show history action sheet in toolbar if iOS 15 or up
                        HistoryActionView(labelText: "Clear")
                    }

                    Spacer()

                    // If we're on history or bookmarks views
                    if tabSelect == 0 || tabSelect == 2 {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        navModel.currentSheet = nil
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
            .navigationViewStyle(.stack)
            .environment(\.editMode, $editMode)
        }
        .onAppear {
            currentUrl = webModel.webView.url?.absoluteString ?? "No URL found"
        }
        .blur(radius: navModel.blurRadius)
        .applyTheme(followSystemTheme ? nil : (useDarkTheme ? "dark" : "light"))
    }

    func getNavigationBarTitle(_ tabSelect: Int) -> String {
        switch tabSelect {
        case 0:
            return "Bookmarks"
        case 1:
            return "Actions"
        case 2:
            return "History"
        default:
            return ""
        }
    }

    @ViewBuilder
    var navigationSwitchView: some View {
        if tabSelect == 0 {
            NavigationLink("", destination: EditBookmarkView(bookmark: $currentBookmark), isActive: $showEditing)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(currentUrl: "")
    }
}
