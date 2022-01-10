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
                AppIconButtonView(imageKey: "GradientsImage", iconKey: "GradientsAppIcon", iconName: "Gradients", author: "Idiocy Max")
                AppIconButtonView(imageKey: "SunsetImage", iconKey: "SunsetAppIcon", iconName: "Sunset", author: "kingbri")
                AppIconButtonView(imageKey: "OceanImage", iconKey: "OceanAppIcon", iconName: "Ocean", author: "kingbri")
                AppIconButtonView(imageKey: "JustPinkImage", iconKey: "JustPinkAppIcon", iconName: "Just Pink", author: "kingbri")
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
