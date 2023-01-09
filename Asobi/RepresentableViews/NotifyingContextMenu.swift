//
//  NotifyingContextMenu.swift
//  Asobi
//
//  Created by Brian Dashore on 1/9/23.
//
//  Inspired from https://stackoverflow.com/questions/72714335/swiftui-notification-when-contextmenu-is-dismissed-ios
//

import SwiftUI

struct NotifyingContextMenu<Content: View>: UIViewRepresentable {
    @ViewBuilder var parentView: Content
    let actions: [UIAction]
    let title: String?
    let willDisplay: (() -> Void)?
    let willEnd: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIContextMenuInteractionDelegate{
        var contextMenu: UIContextMenuInteraction!

        let parent: NotifyingContextMenu
        init(_ parent: NotifyingContextMenu) {
            self.parent = parent
        }

        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { [self]
                suggestedActions in

                return UIMenu(title: parent.title ?? "", children: parent.actions)
            })
        }

        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            print(#function)
            parent.willDisplay?()
        }

        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
            print(#function)
            parent.willEnd?()
        }
    }

    func makeUIView(context: Context) -> UIView {
        // Add a hosting controller shim to access the ContextMenu properties
        let hostingWrapper = UIHostingController(rootView: parentView).view!
        context.coordinator.contextMenu = UIContextMenuInteraction(delegate: context.coordinator)
        hostingWrapper.addInteraction(context.coordinator.contextMenu)
        return hostingWrapper
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
