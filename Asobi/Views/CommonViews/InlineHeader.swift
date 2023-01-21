//
//  InlineHeader.swift
//  Asobi
//
//  Created by Brian Dashore on 1/10/23.
//

import SwiftUI

struct InlineHeader: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        if #available(iOS 16, *) {
            Text(title)
        } else if #available(iOS 15, *) {
            Text(title)
                .listRowInsets(EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 0))
        } else {
            Text(title)
        }
    }
}
