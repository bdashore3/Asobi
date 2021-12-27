//
//  AppIconButtonView.swift
//  Asobi
//
//  Created by Brian Dashore on 12/26/21.
//

import SwiftUI

struct AppIconButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("selectedIconKey") var selectedIconKey = "AppImage"
    @AppStorage("navigationAccent") var navigationAccent: Color = .red
    
    let imageKey: String
    let iconKey: String?
    let iconName: String
    let author: String
    
    var body: some View {
        VStack {
            Button(action: {
                UIApplication.shared.setAlternateIconName(iconKey)
                selectedIconKey = imageKey
            }, label: {
                Image(imageKey)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
            })

            VStack {
                Text(iconName)
                Text("by \(author)")
            }
            .foregroundColor(selectedIconKey == imageKey ? navigationAccent : (colorScheme == .light ? .black : .white))
            .font(.caption2, weight: selectedIconKey == imageKey ? .bold : .regular)
        }
    }
}

struct AppIconButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconButtonView(imageKey: "AppImage", iconKey: nil, iconName: "Default", author: "kingbri")
    }
}
