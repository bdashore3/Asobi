//
//  BookmarkView.swift
//  Asobi
//
//  Created by Brian Dashore on 10/15/21.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @Environment(\.presentationMode) var presentationMode
    
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
                    BookmarkView(currentBookmark: $currentBookmark, showEditing: $showEditing, dismissLibraryView: $dismissSelf)
                } else {
                    Form {
                        Section(header: "Current URL", footer: "Tap the textbox to copy the URL!") {
                            HStack {
                                Text(currentUrl ?? "No URL found")
                                
                                Spacer()
                                
                                Text(isCopiedButton ? "Copied!" : "Copy")
                                    .opacity(0.6)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                isCopiedButton = true
                                
                                UIPasteboard.general.string = currentUrl
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                    isCopiedButton = false
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .onChange(of: dismissSelf) { _ in                
                presentationMode.wrappedValue.dismiss()
            }
            .background(
                navigationSwitchView
            )
            .navigationBarTitle(tabSelect == 0 ? "Bookmarks": "History", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if tabSelect == 0 {
                        Button("Add") {
                            showEditing.toggle()
                        }
                    } else {
                        Button("Actions") {
                            showEditing.toggle()
                        }
                    }

                    Spacer()
                    
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
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
