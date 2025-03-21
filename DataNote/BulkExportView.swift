//
//  BulkExportView.swift
//  RecordText
//
//  Created by Michael Swarm on 3/5/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct BulkExportView: View {
    @Environment(\.modelContext) private var modelContext
    //@Environment(ExportModel.self) var exportModel // If environment, then why init parameter???
    @Environment(CollectionModel.self) var collection
    @State private var isShowingFolderPicker = false
    
    //@Bindable var shared: ExportModel // TBD: Get BulkExportView to use shared model, not view state.
    /*init(sharedModel: ExportModel) {
        self.shared = sharedModel
    }*/
    
    var body: some View {
        //VStack {
            /*if shared.isRunning {
                ProgressBar(progress: $shared.progress) // ProgressView + ProgressModel wrapper
            } else {*/
                Button {
                    isShowingFolderPicker = true
                } label: {
                    Label("Export All", systemImage: "square.and.arrow.up.on.square")
                }
                .disabled(collection.isRunning)
                //.disabled(exportModel.isRunning)
                // File importer is used as folder picker for user to select a destination folder to export to.
                .fileImporter( isPresented: $isShowingFolderPicker, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
                    print("Folder Picker...")
                    do {
                        let urls = try result.get()
                        let folderURL = urls.first!
                        Task {
                            await collection.exportAllFiles(to: folderURL)
                            //await shared.exportAllFiles(to: folderURL)
                        }
                    }
                    catch{
                        print("Error selecting export folder \(error.localizedDescription)")
                    }
                    
                } onCancellation: {
                    print("Export All Cancel...")
                }
                .fileDialogConfirmationLabel("Export All") // MacOS
            //}
        //}
    }
}

// Can not show file picker in preview. 
#Preview {
    /*var sharedModelContainer: ModelContainer = {
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

    let shared = ExportModel(modelContext: sharedModelContainer.mainContext)*/
    BulkExportView()
    // BulkExportView(sharedModel: shared)
}
