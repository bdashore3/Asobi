//
//  DynamicContextMenu.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/23.
//
//  Switches between native SwiftUI and Notifying context menus depending on the OS
//

import SwiftUI

struct DynamicContextMenu: ViewModifier {
    let buttons: [ContextMenuButton]
    let title: String?
    let willDisplay: (() -> Void)?
    let willEnd: (() -> Void)?

    func body(content: Content) -> some View {
        if UIDevice.current.deviceType == .mac {
            content
                .contextMenu {
                    ForEach(buttons) { button in
                        button.toSwiftUIButton()
                    }
                }
        } else {
            NotifyingContextMenu(
                parentView: { content },
                actions: buttons.map { $0.toUIAction() },
                title: title,
                willDisplay: willDisplay,
                willEnd: willEnd
            )
            .fixedSize()
        }
    }
}
