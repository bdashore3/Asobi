//
//  AboutView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct AboutView: View {
    @AppStorage("selectedIconKey") var selectedIconKey = "AppImage"

    var body: some View {
        List {
            Section {
                ListRowTextView(leftText: "Version", rightText: Application.shared.appVersion)
                ListRowTextView(leftText: "Build number", rightText: Application.shared.appBuild)
                ListRowTextView(leftText: "Build type", rightText: Application.shared.buildType)
                ListRowExternalLinkView(text: "App website", link: "https://kingbri.dev/asobi")
                ListRowExternalLinkView(text: "GitHub repository", link: "https://github.com/bdashore3/Asobi")
                ListRowExternalLinkView(text: "Discord support", link: "https://kingbri.dev/discord")
            } header: {
                VStack(alignment: .center) {
                    Image(selectedIconKey)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 100 * 0.225, style: .continuous))
                        .padding(.top, 24)

                    Text("Asobi is a free and open source browser application developed by Brian Dashore under the Apache-2.0 license.")
                        .textCase(.none)
                        .foregroundColor(.label)
                        .font(.body)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 0))
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("About")
    }
}

#if DEBUG
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
#endif
