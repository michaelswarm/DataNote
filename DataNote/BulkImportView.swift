//
//  BulkImportView.swift
//  RecordText
//
//  Created by Michael Swarm on 3/5/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import Foundation

// Separate progress view from button??? (Integrate separate progress bar into action bar.)
// Then this becomes BulkImportButton???
// Same for BulkExportView...
struct BulkImportView: View {
    @Environment(\.modelContext) private var modelContext
    //@Environment(ExportModel.self) var exportModel
    @Environment(CollectionModel.self) var collection
    //@Environment(ImportModel.self) var importModel
    //@Environment(DeleteModel.self) var deleteModel
    @State private var isShowingFolderPicker = false
    
    /*@Bindable var shared: ExportModel // TBD: Get BulkExportView to use shared model, not view state.
    init(sharedModel: ExportModel) {
        self.shared = sharedModel
    }*/

    var body: some View {
        /*if shared.isRunning {
            ProgressBar(progress: $shared.progress) // ProgressView + ProgressModel wrapper
        } else {*/
            Button {
                isShowingFolderPicker = true
            } label: {
                Label("Import All", systemImage: "square.and.arrow.down.on.square")
            }
            .disabled(collection.isRunning)
            //.disabled(exportModel.isRunning)
            .fileImporter(
                isPresented: $isShowingFolderPicker,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let folderURL = urls.first {
                        Task {
                            await collection.importAllFiles(from: folderURL)
                            //await shared.importAllFiles(from: folderURL)
                        }
                    }
                case .failure(let error):
                    print("Error selecting folder: \(error)")
                }
            }
            .fileDialogConfirmationLabel("Import All") // MacOS
        //}
    }
}

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

    let shared = ExportModel(modelContext: sharedModelContainer.mainContext)
    BulkImportView(sharedModel: shared)*/
    BulkImportView()
}
