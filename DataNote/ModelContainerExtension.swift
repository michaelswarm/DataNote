//
//  ModelContainerExtension.swift
//  DataNote
//
//  Created by Michael Swarm on 3/17/25.
//

import Foundation
import SwiftData

/*
 sharedInMemory: Static, lazily-initialized property shared within an extension of the ModelContainer class. This property provides a singleton instance of ModelContainer configured for in-memory storage of Note objects.
 
 Move to class singleton from app property. Use of class namespace avoids pass by parameter.
 Used by previews and models. 
 */

// Useful for previews. Move out of app.
extension ModelContainer {
    // Use for development and previews
    static var sharedInMemory: ModelContainer = {
        let schema = Schema([Note.self,])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true) // Memory only during development
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Use for production and test
    static var shared: ModelContainer = {
        let schema = Schema([Note.self,])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false) // Memory only during development
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
