//
//  ConditionalListStyle.swift
//  Asobi
//
//  Created by Brian Dashore on 1/21/23.
//
//  Conditionally switches a list style between grouped and inset grouped for Mac vs iOS
//

import SwiftUI

struct ConditionalListStyle: ViewModifier {
    func body(content: Content) -> some View {
        if UIDevice.current.deviceType == .mac {
            content
                .listStyle(.insetGrouped)
        } else {
            content
                .listStyle(.grouped)
        }
    }
}
