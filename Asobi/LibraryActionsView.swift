//
//  LibraryActionsView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/5/22.
//

import SwiftUI

struct LibraryActionsView: View {
    @Environment(\.presentationMode) var presentationMode

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @Binding var currentUrl: String
    @State private var isCopiedButton = false

    var body: some View {
        Form {
            Section(header: "Current URL", footer: "Tap the textbox to copy the URL!") {
                HStack {
                    Text(currentUrl)
                        .lineLimit(1)

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

            Section {
                Button("Find in page") {
                    webModel.showFindInPage = true
                    navModel.currentSheet = nil
                }

                // Can only use if statements in SwiftUI views. Only show inline button if iOS 14 or below
                if #available(iOS 15, *) {}
                else if UIDevice.current.deviceType == .phone || UIDevice.current.deviceType == .pad {
                    HistoryActionView(labelText: "Clear browsing data")
                }
            }
        }
    }
}

struct LibraryActionsView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryActionsView(currentUrl: .constant(""))
    }
}
