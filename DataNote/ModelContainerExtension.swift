//
//  ModelContainerExtension.swift
//  DataNote
//
//  Created by Michael Swarm on 3/17/25.
//

import Foundation
import SwiftData

// Useful for previews. Move out of app. 
extension ModelContainer {
    static var shared: ModelContainer = {
        let schema = Schema([
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true) // Memory only during development
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
