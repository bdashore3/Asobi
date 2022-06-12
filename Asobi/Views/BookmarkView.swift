//
//  BookmarkView.swift
//  Asobi
//
//  Created by Brian Dashore on 10/22/21.
//

import SwiftUI

struct BookmarkView: View {
    @AppStorage("defaultUrl") var defaultUrl = ""
    @AppStorage("useStatefulBookmarks") var useStatefulBookmarks = false

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    let backgroundContext = PersistenceController.shared.backgroundContext

    @FetchRequest(
        entity: Bookmark.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bookmark.orderNum, ascending: true),
            NSSortDescriptor(keyPath: \Bookmark.name, ascending: true)
        ]
    ) var bookmarks: FetchedResults<Bookmark>

    @Binding var currentBookmark: Bookmark?
    @Binding var showEditing: Bool

    var body: some View {
        if bookmarks.isEmpty {
            Text("It looks like your bookmarks are empty. Try adding some!")
                .padding()
        } else {
            List {
                ForEach(bookmarks, id: \.self) { bookmark in
                    // Check for iOS 15 and ONLY iOS 15
                    if #available(iOS 15.0, *), UIDevice.current.deviceType != .mac {
                        ListRowLinkView(text: bookmark.name ?? "Unknown", link: bookmark.url ?? "", useStatefulBookmarks: useStatefulBookmarks)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Edit") {
                                    currentBookmark = bookmark

                                    showEditing = true
                                }
                                .tint(.blue)

                                Button("Delete") {
                                    PersistenceController.shared.delete(bookmark, context: backgroundContext)
                                }
                                .tint(.red)
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button("Set as default") {
                                    if let bookmarkUrl = bookmark.url {
                                        defaultUrl = bookmarkUrl
                                    }
                                }
                                .tint(.green)
                            }
                    } else {
                        ListRowLinkView(text: bookmark.name ?? "Unknown", link: bookmark.url ?? "", useStatefulBookmarks: useStatefulBookmarks)
                            .contextMenu {
                                Button {
                                    currentBookmark = bookmark

                                    showEditing = true
                                } label: {
                                    Label("Edit bookmark", systemImage: "pencil")
                                }

                                Button {
                                    PersistenceController.shared.delete(bookmark, context: backgroundContext)
                                } label: {
                                    Label("Delete bookmark", systemImage: "trash")
                                }

                                Button {
                                    if let bookmarkUrl = bookmark.url {
                                        defaultUrl = bookmarkUrl
                                    }
                                } label: {
                                    Label("Set as default URL", systemImage: "archivebox")
                                }
                            }
                    }
                }
                .onMove(perform: moveItem)
                .onDelete(perform: removeItem)
            }
            .listStyle(.grouped)
        }
    }

    func removeItem(at offsets: IndexSet) {
        for index in offsets {
            if let bookmark = bookmarks[safe: index] {
                PersistenceController.shared.delete(bookmark, context: backgroundContext)
            }
        }
    }

    func moveItem(from source: IndexSet, to destination: Int) {
        var changedBookmarks = bookmarks.map { $0 }

        changedBookmarks.move(fromOffsets: source, toOffset: destination)

        for reverseIndex in stride(from: changedBookmarks.count - 1, through: 0, by: -1) {
            changedBookmarks[reverseIndex].orderNum = Int16(reverseIndex)
        }

        PersistenceController.shared.save(backgroundContext)
    }
}

struct BookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkView(currentBookmark: .constant(nil), showEditing: .constant(false))
    }
}
