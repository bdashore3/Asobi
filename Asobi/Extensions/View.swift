//
//  View.swift
//  Asobi
//
//  Created by Brian Dashore on 12/27/21.
//

import SwiftUI

extension View {
    func applyTheme(_ colorScheme: String?) -> some View {
        modifier(ApplyTheme(colorScheme: colorScheme))
    }

    func disabledAppearance(_ disabled: Bool = false) -> some View {
        modifier(DisabledAppearance(disabled: disabled))
    }

    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        self.modifier(WillDisappearModifier(callback: perform))
    }
}
