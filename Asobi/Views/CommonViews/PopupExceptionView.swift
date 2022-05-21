//
//  PopupExceptionView.swift
//  Asobi
//
//  Created by Brian Dashore on 5/20/22.
//

import SwiftUI

struct PopupExceptionView: View {    
    @EnvironmentObject var webModel: WebViewModel

    let backgroundContext = PersistenceController.shared.backgroundContext

    @FetchRequest(
        entity: AllowedPopup.entity(),
        sortDescriptors: []
    ) var allowedPopups: FetchedResults<AllowedPopup>

    @State private var showAddAlert = false
    @State private var newAllowedSiteUrl = ""

    var body: some View {
        Form {
            Section(header: "Add a website") {
                HStack {
                    TextField("Enter URL", text: $newAllowedSiteUrl)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .lineLimit(1)

                    Spacer()

                    Button("Add") {
                        let popupRequest = AllowedPopup.fetchRequest()
                        popupRequest.predicate = NSPredicate(format: "url == %@", newAllowedSiteUrl)
                        popupRequest.fetchLimit = 1

                        guard let count = try? backgroundContext.count(for: popupRequest) else {
                            return
                        }
                        
                        if count < 1 {
                            let newAllowedSite = AllowedPopup(context: backgroundContext)
                            newAllowedSite.url = newAllowedSiteUrl

                            PersistenceController.shared.save(backgroundContext)
                        }
                    }
                }
            }

            Section(header: "Allowed websites") {
                if allowedPopups.isEmpty {
                    Text("There are no allowed popup websites")
                } else {
                    ForEach(allowedPopups, id: \.self) { allowedPopup in
                        Text(allowedPopup.url ?? "No URL found")
                    }
                    .onDelete(perform: removeItem)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .onAppear {
            if let url = webModel.webView.url {
                newAllowedSiteUrl = url.absoluteString
            }
        }
        .navigationTitle("Popup exceptions")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func removeItem(at offsets: IndexSet) {
        for index in offsets {
            let allowedPopup = allowedPopups[index]
            PersistenceController.shared.delete(allowedPopup, context: backgroundContext)
        }
    }
}

struct PopupExceptionView_Previews: PreviewProvider {
    static var previews: some View {
        PopupExceptionView()
    }
}
