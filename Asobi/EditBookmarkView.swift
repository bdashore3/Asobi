//
//  AddBookmarkView.swift
//  Asobi
//
//  Created by Brian Dashore on 10/16/21.
//

import CoreData
import SwiftUI

struct EditBookmarkView: View {
    @Environment(\.managedObjectContext) var context

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @State private var bookmarkName = ""
    @State private var bookmarkUrl = ""
    @Binding var bookmark: Bookmark?
    @State private var showUrlError = false

    var body: some View {
        NavigationView {
            Form {
                // Because onAppear doesn't work properly with sheet + form
                Section {
                    TextField("Enter title", text: $bookmarkName)
                    TextField("Enter URL", text: $bookmarkUrl)
                        .textCase(.lowercase)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                .onAppear {
                    bookmarkName = bookmark?.name ?? webModel.webView.title ?? ""
                    bookmarkUrl = bookmark?.url ?? webModel.webView.url?.absoluteString ?? ""
                    
                    if !(bookmarkUrl.hasPrefix("http://") || bookmarkUrl.hasPrefix("https://")) {
                        bookmarkUrl = "https://\(bookmarkUrl)"
                    }
                }
            }
            .alert(isPresented: $showUrlError) {
                Alert(
                    title:Text("Empty fields"),
                    message: Text("The bookmark title and URL cannot be empty. Please input the valid fields"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationBarTitle("Editing Bookmark", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if bookmarkUrl == "" || bookmarkName == "" {
                            showUrlError.toggle()
                            
                            return
                        }
                        
                        if let unwrappedBookmark = bookmark {
                            // Update an existing bookmark
                            unwrappedBookmark.name = bookmarkName
                            unwrappedBookmark.url = bookmarkUrl
                        } else {
                            // Set a new bookmark
                            let bookmark = Bookmark(context: context)
                            bookmark.name = bookmarkName
                            bookmark.url = bookmarkUrl
                        }
                        
                        do {
                            try context.save()

                            navModel.currentSheet = nil
                        } catch {
                            print("Coredata Error: \(error.localizedDescription)")
                        }
                        
                        bookmark = nil
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct EditBookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        EditBookmarkView(bookmark: .constant(nil))
    }
}
