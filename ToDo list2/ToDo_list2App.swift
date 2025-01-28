//
//  ToDo_list2App.swift
//  ToDo list2
//
//  Created by Виктория Струсь on 28.01.2025.
//

import SwiftUI

@main
struct ToDo_list2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
