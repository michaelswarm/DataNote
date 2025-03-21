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
    @State var collection = CollectionModel.shared // State required for binding and environment.
    // @State var prototype = PrototypeModel.shared // EXPERIMENT
    
    var body: some Scene {
        WindowGroup {
            MainView(sortDescriptor: sortOption.sortDescriptor, sortOption: $sortOption, config: config, selection: $collection.selectedNote)
                .modelContext(ModelContainer.shared.mainContext) // Set a .modelContext in view's environment to use Query 
                .environment(collection)
        }
        
#if os(macOS)
        .commands {
            CommandGroup(after: .newItem) {
                Divider() // Separate import and export from other file menu items
                if config.showImportAll {
                    BulkImportView()
                        .environment(collection) // button enable-disable
                }
                if config.showExportAll {
                    BulkExportView()
                        .environment(collection) // button enable-disable
                }
                Divider() // Separate delete to make it less likely to be accidentally chosen.
                if config.showDeleteAll {
                    BulkDeleteView(selection: $collection.selectedNote)
                        .environment(collection) // button enable-disable
                }
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
