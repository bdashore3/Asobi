//
//  FindInPageView.swift
//  Asobi
//
//  Created by Brian Dashore on 1/4/22.
//

import SwiftUI

struct FindInPageView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    @AppStorage("navigationAccent") var navigationAccent: Color = .red

    var body: some View {
        HStack {
            TextField(
                "",
                text: $webModel.findQuery,
                onEditingChanged: { changed in
                    if UIDevice.current.deviceType != .mac {
                        navModel.isKeyboardShowing = changed
                    }
                },
                onCommit: {
                    webModel.executeFindInPage()
                }
            )
            // MacCatalyst breaks if autocorrect is enabled
            .disableAutocorrection(UIDevice.current.deviceType == .mac ? true : false)

            if webModel.totalFindResults == 0 {
                Text("No results")
                    .foregroundColor(.gray)
            } else if webModel.currentFindResult != -1, webModel.totalFindResults != -1 {
                Text("\(webModel.currentFindResult)/\(webModel.totalFindResults)")
                    .foregroundColor(.gray)
            }

            Button(action: {
                webModel.executeFindInPage()
            }, label: {
                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 4)
            })
            .keyboardShortcut(.defaultAction)

            Button(action: {
                webModel.moveFindInPageResult(isIncrementing: false)
            }, label: {
                Image(systemName: "chevron.up")
                    .padding(.horizontal, 4)
            })

            Button(action: {
                webModel.moveFindInPageResult(isIncrementing: true)
            }, label: {
                Image(systemName: "chevron.down")
                    .padding(.horizontal, 4)
            })

            Button(action: {
                webModel.resetFindInPage()
                webModel.showFindInPage.toggle()
            }, label: {
                Image(systemName: "xmark")
                    .padding(.horizontal, 4)
            })
            .keyboardShortcut(.cancelAction)
        }
        .padding(10)
        .accentColor(navigationAccent)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(10)
        .transition(AnyTransition.move(edge: .bottom))
        .animation(.easeInOut(duration: 0.3))
        .padding(.horizontal, 4)
    }
}

struct FindInPageView_Previews: PreviewProvider {
    static var previews: some View {
        FindInPageView()
    }
}
