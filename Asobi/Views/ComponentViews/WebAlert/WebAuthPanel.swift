//
//  WebAuthPanel.swift
//  Asobi
//
//  Created by Brian Dashore on 1/21/23.
//

import SwiftUI

struct WebAuthPanel: View {
    @EnvironmentObject var webModel: WebViewModel

    @State private var usernameText: String = ""
    @State private var passwordText: String = ""

    var body: some View {
        GroupBox {
            VStack(spacing: 20) {
                Text(webModel.webAlertMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 0) {
                    TextField("User Name", text: $usernameText)
                    Divider()
                    SecureField("Password", text: $passwordText)
                }
                .textFieldStyle(PaddedTextFieldStyle(isRounded: false))
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .cornerRadius(5)

                HStack(spacing: 30) {
                    Button("Cancel") {
                        webModel.webAuthAction?(.cancelAuthenticationChallenge, nil)
                        webModel.presentAlert(nil)
                    }

                    Button {
                        let credentials = URLCredential(user: usernameText, password: passwordText, persistence: .forSession)
                        webModel.webAuthAction?(.useCredential, credentials)
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

struct WebAuthPanel_Previews: PreviewProvider {
    static var previews: some View {
        WebAuthPanel()
    }
}
