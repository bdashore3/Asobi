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
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var webModel: WebViewModel

    @Binding var bookmark: Bookmark?

    @State private var bookmarkName = ""
    @State private var bookmarkUrl = ""
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if bookmarkUrl == "" || bookmarkName == "" {
                            showUrlError.toggle()

                            return
                        }

                        if let unwrappedBookmark = bookmark {
                            // Update an existing bookmark
                            unwrappedBookmark.name = bookmarkName.trimmingCharacters(in: .whitespaces)
                            unwrappedBookmark.url = bookmarkUrl.trimmingCharacters(in: .whitespaces)
                        } else {
                            // Set a new bookmark
                            let bookmark = Bookmark(context: context)
                            bookmark.name = bookmarkName.trimmingCharacters(in: .whitespaces)
                            bookmark.url = bookmarkUrl.trimmingCharacters(in: .whitespaces)
                        }

                        PersistenceController.shared.save()

                        presentationMode.wrappedValue.dismiss()

                        bookmark = nil
                    }
                    .keyboardShortcut(.defaultAction)
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
