//
//  WebPromptPanel.swift
//  Asobi
//
//  Created by Brian Dashore on 1/21/23.
//

import SwiftUI

struct WebPromptPanel: View {
    @EnvironmentObject var webModel: WebViewModel

    @State private var inputText: String = ""

    var body: some View {
        GroupBox {
            VStack(spacing: 20) {
                Text(webModel.webAlertMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("", text: $inputText)
                    .textFieldStyle(PaddedTextFieldStyle(isRounded: true))
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)

                HStack(spacing: 30) {
                    Button("Cancel") {
                        webModel.webPromptAction?(nil)
                        webModel.presentAlert(nil)
                    }

                    Button {
                        webModel.webPromptAction?(inputText)
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

struct WebPromptPanel_Previews: PreviewProvider {
    static var previews: some View {
        WebPromptPanel()
    }
}
