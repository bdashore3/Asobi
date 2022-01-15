//
//  AboutView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct AboutView: View {
    @AppStorage("selectedIconKey") var selectedIconKey = "AppImage"

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Image(selectedIconKey)
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(25)

            Text("Asobi is a free and open source browser application developed by Brian Dashore under the Apache-2.0 license.")
                .padding()

            List {
                ListRowTextView(leftText: "Version", rightText: UIApplication.appVersion())
                ListRowTextView(leftText: "Build number", rightText: UIApplication.appBuild())
                ListRowTextView(leftText: "Build type", rightText: UIApplication.buildType())
                ListRowLinkView(text: "GitHub repository", link: "https://github.com/bdashore3/Cubari-iOS")
                ListRowLinkView(text: "Discord support", link: "https://discord.gg/pswt7by")
            }
            .listStyle(InsetGroupedListStyle())
        }
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
