//
//  ApplyTheme.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/23.
//

import Introspect
import SwiftUI

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
