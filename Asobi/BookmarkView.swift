//
//  BookmarkBiew.swift
//  Asobi
//
//  Created by Brian Dashore on 10/22/21.
//

import SwiftUI

struct BookmarkView: View {
    @EnvironmentObject var model: WebViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        entity: Bookmark.entity(),
        sortDescriptors: []
    ) var bookmarks: FetchedResults<Bookmark>
    
    @Binding var currentBookmark: Bookmark?
    @Binding var showEditing: Bool
    @Binding var dismissLibraryView: Bool
    
    var body: some View {
        if bookmarks.isEmpty {
            Text("It looks like your bookmarks are empty. Try adding some!")
                .padding()
        } else {
            List {
                // Add NavigationModel to use the common ListRowLink views
                ForEach(bookmarks, id: \.self) { bookmark in
                    if #available(iOS 15.0, *) {
                        HStack {
                            Text(bookmark.name ?? "Unknown")
                                
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            model.loadUrl(bookmark.url ?? "")
                            
                            dismissLibraryView.toggle()
                        }
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
                        HStack {
                            Text(bookmark.name ?? "Unknown")
                                
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            model.loadUrl(bookmark.url ?? "")
                            
                            dismissLibraryView.toggle()
                        }
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
            .listStyle(.insetGrouped)
        }
    }

    func removeItem(at offsets: IndexSet) {
        for index in offsets {
            let item = bookmarks[index]
            PersistenceController.shared.delete(item)
        }
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkView(currentBookmark: .constant(nil), showEditing: .constant(false), dismissLibraryView: .constant(false))
    }
}
