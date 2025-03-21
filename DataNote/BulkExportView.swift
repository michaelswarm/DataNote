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
    @Environment(CollectionModel.self) var collection
    
    @State private var isShowingFolderPicker = false

    var body: some View {
        Button {
            isShowingFolderPicker = true
        } label: {
            Label("Export All", systemImage: "square.and.arrow.up.on.square")
        }
        .disabled(collection.isRunning)
        // File importer is used as folder picker for user to select a destination folder to export to.
        .fileImporter( isPresented: $isShowingFolderPicker, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
            print("Folder Picker...")
            do {
                let urls = try result.get()
                let folderURL = urls.first!
                Task {
                    await collection.exportAllFiles(to: folderURL)
                }
            }
            catch{
                print("Error selecting export folder \(error.localizedDescription)")
            }
            
        } onCancellation: {
            print("Export All Cancel...")
        }
        .fileDialogConfirmationLabel("Export All") // MacOS
    }
}

// Can not show file picker in preview. 
#Preview {
    BulkExportView()
}
