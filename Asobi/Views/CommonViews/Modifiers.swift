//
//  Modifiers.swift
//  Asobi
//
//  Created by Brian Dashore on 12/27/21.
//

import Combine
import Introspect
import SwiftUI

// All custom view modifiers go here
struct ApplyTheme: ViewModifier {
    let colorScheme: ColorScheme?

    func body(content: Content) -> some View {
        content
            .introspectViewController { UIViewController in
                switch colorScheme {
                case .dark:
                    UIViewController.overrideUserInterfaceStyle = .dark
                case .light:
                    UIViewController.overrideUserInterfaceStyle = .light
                default:
                    UIViewController.overrideUserInterfaceStyle = .unspecified
                }
            }
    }
}

struct DisabledAppearance: ViewModifier {
    let disabled: Bool

    func body(content: Content) -> some View {
        content
            .disabled(disabled)
            .opacity(disabled ? 0.5 : 1)
    }
}

struct TextFieldClearMode: ViewModifier {
    let clearButtonMode: UITextField.ViewMode

    func body(content: Content) -> some View {
        content
            .introspectTextField { textField in
                textField.clearButtonMode = clearButtonMode
            }
    }
}

struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void

    func body(content: Content) -> some View {
        content
            .background(WillDisappearHandler(onWillDisappear: callback))
    }
}
