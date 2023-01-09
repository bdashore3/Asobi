//
//  AboutButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct LibraryButtonView: View {
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @AppStorage("browserModeEnabled") var browserModeEnabled = false

    var body: some View {
        Button(action: {
            navModel.currentSheet = .library
        }, label: {
            Image(systemName: "book")
                .padding(.horizontal, 4)
        })
        .dynamicContextMenu(
            buttons: getContextMenuButtons(),
            willEnd: {
                navModel.libraryMenuOpen = false
            },
            willDisplay: {
                navModel.libraryMenuOpen = true
            }
        )
    }

    func getContextMenuButtons() -> [ContextMenuButton] {
        var buttons = [
            ContextMenuButton("Copy current URL", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = webModel.webView.url?.absoluteString
            },
            ContextMenuButton("Add bookmark", systemImage: "plus.circle") {
                navModel.currentSheet = .bookmarkEditing
            }
        ]

        if webModel.findInPageEnabled {
            buttons.append(
                ContextMenuButton("Find in page", systemImage: "text.magnifyingglass") {
                    navModel.currentPillView = .findInPage
                }
            )
        }

        if browserModeEnabled {
            buttons.append(
                ContextMenuButton("Go to homepage", systemImage: "ahouse") {
                    webModel.goHome()
                }
            )
        }

        if UIDevice.current.deviceType == .phone {
            buttons.append(
                ContextMenuButton("Refresh page", systemImage: "arrow.clockwise") {
                    webModel.webView.reload()
                }
            )
        }

        return buttons
    }
}

#if DEBUG
struct LibraryButtonView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryButtonView()
    }
}
#endif
