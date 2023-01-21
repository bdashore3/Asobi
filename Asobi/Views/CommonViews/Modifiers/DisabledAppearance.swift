//
//  DisabledAppearance.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/23.
//

import SwiftUI

struct DisabledAppearance: ViewModifier {
    let disabled: Bool

    func body(content: Content) -> some View {
        content
            .disabled(disabled)
            .opacity(disabled ? 0.5 : 1)
    }
}
