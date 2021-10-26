//
//  ListRowView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

// These views were imported from FileBridge

// View alias for a list row with an external link
struct ListRowLinkView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel
    
    private var text: String
    private var link: String
    
    init(displayText: String, innerLink: String) {
        link = innerLink
        text = displayText
    }
    
    var body: some View {
        ZStack {
            Color.clear
            HStack {
                Text(text)
                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                    
                Spacer()
                    
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            webModel.loadUrl(link)
            
            navModel.currentSheet = nil
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
