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
    //@State var prototype = PrototypeModel.shared // EXPERIMENT
    
    // Use lazy init class singleton instead of app property 
    // var context: ModelContext { ModelContainer.shared.mainContext }
    
    var body: some Scene {
        //let exportModel = ExportModel(modelContext: context) // Create shared model here

        WindowGroup {
            MainView(sortDescriptor: sortOption.sortDescriptor, sortOption: $sortOption, config: config, selection: $collection.selectedNote /*, context: context*/) // Why is context passed???
                .modelContainer(for: Note.self)
                //.environment(exportModel)
                .environment(collection) // Use class singleton instead of pass by environment???
                //.environment(prototype)
        }
        
#if os(macOS)
        .commands {
            CommandGroup(after: .newItem) {
                Divider() // Separate import and export from other file menu items
                if config.showImportAll {
                    /*if exportModel.isRunning  { // No way to tell which process is running???
                        ProgressBar(progress: exportModel.progress) // Need binding here, which BulkImportView helps create.
                    }*/
                    BulkImportView()
                    // BulkImportView(sharedModel: exportModel)
                    // Pass all bulk storage action models into environment for button enable-disable
                        //.environment(exportModel)
                        .environment(collection)
                }
                if config.showExportAll {
                    BulkExportView()
                    //BulkExportView(sharedModel: exportModel) // Pass into file menu item button
                    // Pass all bulk storage action models into environment for button enable-disable
                        //.environment(exportModel)
                        .environment(collection)
                }
                Divider() // Separate delete to make it less likely to be accidentally chosen.
                if config.showDeleteAll {
                    BulkDeleteView(selection: $collection.selectedNote)
                        .environment(collection)
                    //BulkDeleteView(sharedModel: exportModel, selection: $collection.selectedNote)
                    // Pass all bulk storage action models into environment for button enable-disable
                        //.environment(exportModel)
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
