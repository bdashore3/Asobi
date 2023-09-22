//
//  GroupBoxStyle.swift
//  Asobi
//
//  Created by Brian Dashore on 7/9/22.
//

import SwiftUI

struct LoadingGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
            configuration.content
        }
        .padding(10)
        .background(Color(uiColor: .systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
