//
//  AppIconPickerView.swift
//  Asobi
//
//  Created by Brian Dashore on 12/26/21.
//

import SwiftUI

struct AppIconPickerView: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem()], spacing: 25) {
                AppIconButtonView(imageKey: "AppImage", iconKey: nil, iconName: "Default", author: "kingbri")
            }
            .padding(.vertical, 10)
        }
    }
}

struct AppIconPickerView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconPickerView()
    }
}
