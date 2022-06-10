//
//  View.swift
//  Asobi
//
//  Created by Brian Dashore on 12/27/21.
//

import Combine
import SwiftUI

extension View {
    // From https://stackoverflow.com/questions/65784294/how-to-detect-if-keyboard-is-present-in-swiftui
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false }
            )
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    // MARK: Modifiers
    func applyTheme(_ colorScheme: ColorScheme?) -> some View {
        modifier(ApplyTheme(colorScheme: colorScheme))
    }

    func disabledAppearance(_ disabled: Bool = false) -> some View {
        modifier(DisabledAppearance(disabled: disabled))
    }

    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        modifier(WillDisappearModifier(callback: perform))
    }
}
