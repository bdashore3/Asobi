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
    
    @EnvironmentObject var model: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel
    
    @State var text: String
    @State var link: String
    @State var subText: String?
    
    var body: some View {
        ZStack {
            Color.clear
            HStack {
                VStack (alignment: .leading) {
                    Text(text)
                        .font(subText != nil ? .subheadline : .body)
                        .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                        .lineLimit(1)
                    
                    if let subText = subText {
                        Text(subText)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                    
                Spacer()
                    
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            model.loadUrl(link)
            
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
