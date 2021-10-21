//
//  BookmarkView.swift
//  Asobi
//
//  Created by Brian Dashore on 10/15/21.
//

import SwiftUI
import CoreData
import SwiftUIX

struct BookmarkView: View {
    @EnvironmentObject var model: WebViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var tabSelect = 0
    @State private var showEditing = false
    
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
            .background(NavigationLink("", destination: EditBookmarkView(), isActive: $showEditing))
            .navigationBarTitle(tabSelect == 0 ? "Bookmarks": "History", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(destination: EditBookmarkView()) {
                        Text("Add")
                    }
                    .disabled(tabSelect != 0)

                    Spacer()
                    
                    EditButton()
                }
                
            }
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
                                    model.bookmarkName = bookmark.name
                                    model.bookmarkUrl = bookmark.url
                                    showEditing = true
                                }
                                .tint(.blue)
                                
                                Button("Delete") {
                                    PersistenceController.shared.delete(bookmark)
                                }
                                .tint(.red)
                            }
                    } else {
                        ListRowLinkView(displayText: bookmark.name ?? "Unknown", innerLink: bookmark.url!)
                            .contextMenu {
                                Button {
                                    model.bookmarkName = bookmark.name
                                    model.bookmarkUrl = bookmark.url
                                    showEditing = true
                                } label: {
                                    Label("Edit bookmark", systemImage: "pencil")
                                }
                            }
                    }
                }
                .onDelete(perform: removeItem)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
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

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkView()
    }
}
