//
//  AlertPanel.swift
//  Asobi
//
//  Created by Brian Dashore on 1/21/23.
//

import SwiftUI

struct WebAlertPanel: View {
    @EnvironmentObject var webModel: WebViewModel

    var body: some View {
        GroupBox {
            VStack(spacing: 20) {
                Text(webModel.webAlertMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Close") {
                    webModel.webAlertAction?()
                    webModel.presentAlert(nil)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .cornerRadius(10)
        .frame(maxWidth: UIDevice.current.deviceType == .phone ? 350 : 600)
    }
}

struct WebAlertPanel_Previews: PreviewProvider {
    static var previews: some View {
        WebAlertPanel()
    }
}
