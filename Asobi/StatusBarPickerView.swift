//
//  StatusBarPickerView.swift
//  Asobi
//
//  Created by Brian Dashore on 4/4/22.
//

import SwiftUI

enum StatusBarPickerType: String, CaseIterable {
    case hide
    case partialHide
    case pin
}

struct StatusBarPickerView: View {
    @AppStorage("statusBarPinType") var statusBarPinType: StatusBarPickerType = .partialHide

    var body: some View {
        List {
            ForEach(StatusBarPickerType.allCases, id: \.self) { item in
                Button {
                    statusBarPinType = item
                } label: {
                    HStack {
                        switch item {
                        case .hide:
                            Text("Hidden")
                        case .partialHide:
                            Text("Partially hidden")
                        case .pin:
                            Text("Pinned")
                        }
                        Spacer()
                        if item.rawValue == statusBarPinType.rawValue {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .accentColor(.primary)
        }
    }
}

struct StatusBarPickerView_Previews: PreviewProvider {
    static var previews: some View {
        StatusBarPickerView()
    }
}
