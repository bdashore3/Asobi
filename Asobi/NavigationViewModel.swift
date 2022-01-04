//
//  NavigationViewModel.swift
//  Asobi
//
//  Created by Brian Dashore on 10/25/21.
//

import SwiftUI

class NavigationViewModel: ObservableObject {
    enum SheetType: Identifiable {
        var id: Int {
            hashValue
        }

        case settings
        case library
        case bookmarkEditing
    }

    @Published var currentSheet: SheetType?
    @Published var isKeyboardShowing = false
    @Published var showNavigationBar = true
}
