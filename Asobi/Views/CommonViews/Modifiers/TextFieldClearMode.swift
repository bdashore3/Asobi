//
//  TextFieldClearMode.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/23.
//

import SwiftUI

struct TextFieldClearMode: ViewModifier {
    let clearButtonMode: UITextField.ViewMode

    func body(content: Content) -> some View {
        content
            .introspectTextField { textField in
                textField.clearButtonMode = clearButtonMode
            }
    }
}
