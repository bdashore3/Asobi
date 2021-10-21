//
//  ListRowView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

// These views were imported from FileBridge

// View alias for a list row with an external link
struct ListRowLinkView: View {
    @EnvironmentObject var model: WebViewModel
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @Environment(\.presentationMode) var presentationMode
    
    private var text: String
    private var link: String
    
    init(displayText: String, innerLink: String) {
        link = innerLink
        text = displayText
    }
    
    var body: some View {
        HStack {
            Button(text) {
                model.loadUrl(link)
            }
            .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                
            Spacer()
                
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}

struct ListRowTextView: View {
    private var leftText: String
    private var rightText: String?
    private var rightSymbol: String?
    
    init(leftText: String, rightText: String?, rightSymbol: String?) {
        self.leftText = leftText
        self.rightText = rightText
        self.rightSymbol = rightSymbol
    }
    
    var body: some View {
        HStack {
            Text(leftText)
                
            Spacer()
            
            if let rightText = rightText {
                Text(rightText)
            } else {
                Image(systemName: rightSymbol!)
                    .foregroundColor(.gray)
            }
        }
    }
}
