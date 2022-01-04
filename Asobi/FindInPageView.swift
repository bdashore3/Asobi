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

    @State private var findQuery = ""

    var body: some View {
        HStack {
            TextField("", text: $findQuery, onEditingChanged: { changed in
                if UIDevice.current.deviceType != .mac {
                    navModel.isKeyboardShowing = changed
                }
            })
            
            if webModel.totalFindResults == 0 {
                Text("No results")
                    .foregroundColor(.gray)
            }
            else if webModel.currentFindResult != -1 && webModel.totalFindResults != -1 {
                Text("\(webModel.currentFindResult)/\(webModel.totalFindResults)")
                    .foregroundColor(.gray)
            }
            
            Button (action: {
                if !findQuery.isEmpty {
                    webModel.webView.evaluateJavaScript("undoFindHighlights()")
                    webModel.webView.evaluateJavaScript("findAndHighlightQuery(\"\(findQuery)\")")
                    webModel.webView.evaluateJavaScript("scrollToFindResult(0)")
                }
            }, label: {
                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 4)
            })
            .keyboardShortcut(.defaultAction)

            Button (action: {
                if webModel.totalFindResults == -1 || webModel.totalFindResults == 0 {
                    return
                }
                
                webModel.currentFindResult -= 1

                if webModel.currentFindResult < 1 {
                    webModel.currentFindResult = webModel.totalFindResults
                }
                    
                webModel.webView.evaluateJavaScript("scrollToFindResult(\(webModel.currentFindResult - 1))")
            }, label: {
                Image(systemName: "chevron.up")
                    .padding(.horizontal, 4)
            })

            Button (action: {
                if webModel.totalFindResults == -1 || webModel.totalFindResults == 0 {
                    return
                }

                webModel.currentFindResult += 1

                if webModel.currentFindResult > webModel.totalFindResults {
                    webModel.currentFindResult = 1
                }

                webModel.webView.evaluateJavaScript("scrollToFindResult(\(webModel.currentFindResult - 1))")
            }, label: {
                Image(systemName: "chevron.down")
                    .padding(.horizontal, 4)
            })

            Button (action: {
                webModel.currentFindResult = -1
                webModel.totalFindResults = -1
                webModel.webView.evaluateJavaScript("undoFindHighlights()")
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
