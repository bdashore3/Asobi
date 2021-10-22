//
//  BookmarkView.swift
//  Asobi
//
//  Created by Brian Dashore on 10/15/21.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    @EnvironmentObject var model: WebViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var tabSelect = 0
    @State private var showEditing = false
    @State private var currentBookmark: Bookmark?
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(
        entity: Bookmark.entity(),
        sortDescriptors: []
    ) var bookmarks: FetchedResults<Bookmark>
    
    @State var editMode: EditMode = .inactive
    
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
                    listView
                } else {
                    VStack {
                        Text("History")
                    }
                }
                
                Spacer()
            }
            .background(NavigationLink("", destination: EditBookmarkView(bookmark: $currentBookmark), isActive: $showEditing))
            .navigationBarTitle(tabSelect == 0 ? "Bookmarks": "History", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    
                    if tabSelect == 0 {
                        Button("Add") {
                            showEditing.toggle()
                        }
                    } else {
                        Button("Actions") {
                            print("Actions pressed")
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
    var listView: some View {
        if bookmarks.isEmpty {
            Text("It looks like your bookmarks are empty. Try adding some!")
        } else {
            List {
                ForEach(bookmarks, id: \.self) { bookmark in
                    if #available(iOS 15.0, *) {
                        ListRowLinkView(displayText: bookmark.name ?? "Unknown", innerLink: bookmark.url!)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Edit") {
                                    currentBookmark = bookmark

                                    showEditing = true
                                }
                                .tint(.blue)
                                
                                Button("Delete") {
                                    PersistenceController.shared.delete(bookmark)
                                }
                                .tint(.red)
                            }
                    } else {
                        // Clicking outside the text doesn't dismiss the
                        ListRowLinkView(displayText: bookmark.name ?? "Unknown", innerLink: bookmark.url ?? "Unknown")
                            .contextMenu {
                                Button {
                                    currentBookmark = bookmark

                                    showEditing = true
                                } label: {
                                    Label("Edit bookmark", systemImage: "pencil")
                                }
                                
                                Button {
                                    PersistenceController.shared.delete(bookmark)
                                } label: {
                                    Label("Delete bookmark", systemImage: "trash")
                                }
                            }
                    }
                }
                .onDelete(perform: removeItem)
            }
        }
    }
    
    func removeItem(at offsets: IndexSet) {
        print("Offsets: \(offsets)")
        
        for index in offsets {
            print("Offset index: \(index)")
            
            let item = bookmarks[index]
            PersistenceController.shared.delete(item)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView()
    }
}
