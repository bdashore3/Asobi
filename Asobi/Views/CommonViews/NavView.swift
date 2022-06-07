//
//  NavView.swift
//  Asobi
//
//  Created by Brian Dashore on 6/6/22.
//

import SwiftUI

// Hybrid view to decide whether to use a NavigationStack or legacy NavigationView
// Thanks Mantton!
struct NavView<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
                content()
            }
        } else {
            NavigationView {
                content()
            }
            .navigationViewStyle(.stack)
        }
    }
}
