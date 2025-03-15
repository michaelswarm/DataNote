//
//  DataNoteApp.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

import SwiftUI
import SwiftData

@main
struct DataNoteApp: App {
    @State var sortOption: SortOption = .titleAZ
    @State var config = StorageConfiguration()
    
    var modelContext: ModelContext {
        sharedModelContainer.mainContext
    }
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false) // Memory only during development
        
        do {
            let shared = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Set TextRecord.titles cache from container at startup. (Necessary for persistence.)
            /*let descriptor = FetchDescriptor<Note>()
            let items = try? shared.mainContext.fetch(descriptor)
            if let items = items {
                Note.titles = items.map { $0.title }
            } else {
                print("Could not read items. Can not set TextRecord.titles")
            }*/
            
            return shared
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        let exportModel = ExportModel(modelContext: modelContext) // Create shared model here

        WindowGroup {
            ContentView(sortDescriptor: sortOption.sortDescriptor, sortOption: $sortOption, config: config)
                .modelContainer(for: Note.self)
                .environment(exportModel)
        }
        
#if os(macOS)
        .commands {
            CommandGroup(after: .newItem) {
                Divider() // Separate import and export from other file menu items
                /*if config.showImportAll {
                    BulkImportView(sharedModel: exportModel)
                    // Pass all bulk storage action models into environment for button enable-disable
                        .environment(exportModel)
                }*/
                if config.showExportAll {
                    BulkExportView(sharedModel: exportModel) // Pass into file menu item button
                    // Pass all bulk storage action models into environment for button enable-disable
                        .environment(exportModel)
                }
                Divider() // Separate delete to make it less likely to be accidentally chosen.
                /*if config.showDeleteAll {
                    BulkDeleteView(sharedModel: exportModel, selection: $main.selection)
                    // Pass all bulk storage action models into environment for button enable-disable
                        .environment(exportModel)
                }*/
            }
        }
#endif

#if os(macOS)
        Settings {
            TabView {
                SortSettingsView(sortOption: $sortOption)
                    .tabItem {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                StorageSettingsView(config: config)
                    .tabItem {
                        Label("Storage", systemImage: "archivebox")
                    }
            }
        }
#endif
    }
}
