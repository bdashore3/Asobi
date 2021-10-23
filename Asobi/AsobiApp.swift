//
//  CubariApp.swift
//  Cubari
//
//  Created by Brian Dashore on 8/2/21.
//

import SwiftUI

@main
struct AsobiApp: App {
    @Environment(\.scenePhase) var scenePhase

    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
