//
//  ContextMenuButton.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/23.
//
//  Common button for a dynamic context menu
//

import SwiftUI

struct ContextMenuButton: Identifiable {
    let id: UUID
    let text: String
    let systemImage: String?
    let action: () -> Void

    init(_ text: String, systemImage: String? = nil, action: @escaping () -> Void) {
        id = UUID()
        self.text = text
        self.systemImage = systemImage
        self.action = action
    }

    @ViewBuilder func toSwiftUIButton() -> some View {
        Button {
            action()
        } label: {
            Label(text, systemImage: systemImage ?? "")
        }
    }

    func toUIAction() -> UIAction {
        UIAction(title: text, image: UIImage(systemName: systemImage ?? ""), handler: { _ in
            action()
        })
    }
}
