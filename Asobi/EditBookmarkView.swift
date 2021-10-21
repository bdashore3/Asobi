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

    @EnvironmentObject var model: WebViewModel

    @State var bookmarkName = ""
    @State var bookmarkUrl = ""

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
                    bookmarkName = model.bookmarkName ?? model.webView.title ?? ""
                    bookmarkUrl = model.bookmarkUrl ?? model.webView.url?.absoluteString ?? ""
                }
            }
            .navigationBarTitle("Editing Bookmark", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Do saving here
                        let bookmark = Bookmark(context: context)
                        bookmark.name = bookmarkName
                        bookmark.url = bookmarkUrl
                        
                        do {
                            try context.save()

                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Coredata Error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
}

struct EditBookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        EditBookmarkView()
    }
}
