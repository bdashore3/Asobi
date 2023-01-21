//
//  BookmarkView.swift
//  Asobi
//
//  Created by Brian Dashore on 10/15/21.
//

import CoreData
import SwiftUI

struct LibraryView: View {
    enum LibraryPickerSegment {
        case bookmarks
        case actions
        case history
    }

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @AppStorage("useDarkTheme") var useDarkTheme = false
    @AppStorage("followSystemTheme") var followSystemTheme = true

    @FetchRequest(
        entity: Bookmark.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bookmark.orderNum, ascending: true)
        ]
    ) var bookmarks: FetchedResults<Bookmark>

    @FetchRequest(
        entity: History.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \History.date, ascending: false)
        ]
    ) var history: FetchedResults<History>

    @State var currentUrl: String = "No URL found"

    @State private var dismissSelf = false
    @State private var selectedSegment: LibraryPickerSegment = .bookmarks
    @State private var showEditing = false
    @State private var currentBookmark: Bookmark?
    @State private var isCopiedButton = false
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavView {
            VStack {
                Picker("Tabs", selection: $selectedSegment) {
                    Text("Bookmarks").tag(LibraryPickerSegment.bookmarks)
                    Text("Actions").tag(LibraryPickerSegment.actions)
                    Text("History").tag(LibraryPickerSegment.history)
                }
                .pickerStyle(.segmented)
                .padding()

                Spacer()

                switch selectedSegment {
                case .bookmarks:
                    BookmarkView(bookmarks: bookmarks, currentBookmark: $currentBookmark, showEditing: $showEditing)
                case .actions:
                    LibraryActionsView(currentUrl: $currentUrl)
                case .history:
                    HistoryView(history: history)
                }

                Spacer()
            }
            .background {
                if #available(iOS 16, *) {
                } else {
                    navigationSwitchView
                }
            }
            .overlay {
                switch selectedSegment {
                case .bookmarks:
                    if bookmarks.isEmpty {
                        EmptyInstructionView(title: "No Bookmarks", message: "Add a bookmark from search results")
                    }
                case .actions:
                    EmptyView()
                case .history:
                    if history.isEmpty {
                        EmptyInstructionView(title: "No History", message: "Visit some webpages to build history")
                    }
                }
            }
            .navigationBarTitle("Library", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if selectedSegment == .bookmarks {
                        // Showing bookmark view
                        if #available(iOS 16, *) {
                            NavigationLink("Add", destination:
                                EditBookmarkView()
                                    .onAppear {
                                        showEditing = true
                                    }
                                    .onWillDisappear {
                                        showEditing = false
                                    })
                        } else {
                            Button("Add") {
                                showEditing.toggle()
                            }
                        }
                    } else if #available(iOS 15, *), selectedSegment == .history {
                        // Show history action sheet in toolbar if iOS 15 or up
                        HistoryActionView(labelText: "Clear")
                    }

                    Spacer()

                    // If we're on history or bookmarks views
                    if selectedSegment == .bookmarks || selectedSegment == .history {
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
            .id(showEditing)
            .environment(\.editMode, $editMode)
        }
        .onAppear {
            currentUrl = webModel.webView.url?.absoluteString ?? "No URL found"
        }
        .blur(radius: UIDevice.current.deviceType == .mac ? 0 : navModel.blurRadius)
    }

    @ViewBuilder
    var navigationSwitchView: some View {
        if selectedSegment == .bookmarks {
            NavigationLink("", destination:
                EditBookmarkView(bookmark: currentBookmark)
                    .onWillDisappear { showEditing = false },
                isActive: $showEditing)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(currentUrl: "")
    }
}
