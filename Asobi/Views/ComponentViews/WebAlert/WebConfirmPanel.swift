//
//  WebConfirmPanel'.swift
//  Asobi
//
//  Created by Brian Dashore on 1/21/23.
//

import SwiftUI

struct WebConfirmPanel: View {
    @EnvironmentObject var webModel: WebViewModel

    var body: some View {
        GroupBox {
            VStack(spacing: 20) {
                Text(webModel.webAlertMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 30) {
                    Button("Cancel") {
                        webModel.webConfirmAction?(false)
                        webModel.presentAlert(nil)
                    }

                    Button {
                        webModel.webConfirmAction?(true)
                        webModel.presentAlert(nil)
                    } label: {
                        Text("OK")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .cornerRadius(10)
        .frame(maxWidth: UIDevice.current.deviceType == .phone ? 350 : 600)
    }
}

struct WebConfirmPanel_Previews: PreviewProvider {
    static var previews: some View {
        WebConfirmPanel()
    }
}
