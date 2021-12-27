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
}
