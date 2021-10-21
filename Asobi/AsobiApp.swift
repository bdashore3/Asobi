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
    @StateObject var model: WebViewModel = WebViewModel()

    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(model)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
