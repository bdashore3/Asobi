//
//  WillDisappearModifier.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/23.
//

import SwiftUI

struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content
            .background(WillDisappearHandler(onWillDisappear: callback))
    }
}
