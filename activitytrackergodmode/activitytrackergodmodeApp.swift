//
//  activitytrackergodmodeApp.swift
//  activitytrackergodmode
//
//  Created by Simon Jackson on 5/6/25.
//

import SwiftUI

@main
struct activitytrackergodmodeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
