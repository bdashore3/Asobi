//
//  AboutButtonView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

struct AboutButtonView: View {
    @State var showAbout: Bool = false
    
    var body: some View {
        Button(action: {
            showAbout.toggle()
        }, label: {
            Image(systemName: "info.circle")
        })
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }
}

#if DEBUG
struct AboutButtonView_Previews: PreviewProvider {
    static var previews: some View {
        AboutButtonView()
    }
}
#endif
