//
//  AboutView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Image("AppImage")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(25)
                
            Text("Asobi is a free and open source browser application developed by Brian Dashore under the Apache-2.0 license.")
                .padding()

            List {
                ListRowTextView(leftText: "Version", rightText: UIApplication.appVersion(), rightSymbol: nil)
                ListRowTextView(leftText: "Build Number", rightText: UIApplication.appBuild(), rightSymbol: nil)
                ListRowLinkView(displayText: "GitHub Repository", innerLink: "https://github.com/bdashore3/Cubari-iOS")
                ListRowLinkView(displayText: "Discord Support", innerLink: "https://discord.gg/pswt7by")
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
