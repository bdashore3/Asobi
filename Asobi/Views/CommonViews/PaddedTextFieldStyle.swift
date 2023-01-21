//
//  PaddedTextFieldStyle.swift
//  Asobi
//
//  Created by Brian Dashore on 1/21/23.
//
//  A non-rounded TextField with padding
//

import SwiftUI

struct PaddedTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    let isRounded: Bool

    public func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(5)
            .background(
                colorScheme == .light ? .secondarySystemGroupedBackground : .tertiarySystemGroupedBackground
            )
            .cornerRadius(isRounded ? 5 : 0)
    }
}
