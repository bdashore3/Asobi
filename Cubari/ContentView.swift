//
//  ContentView.swift
//  Cubari
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // Open cubari on launch
        WebView(url: URL(string: "https://cubari.moe"))
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
