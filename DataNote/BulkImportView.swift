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

struct BulkImportView: View {
    @Environment(CollectionModel.self) var collection
    
    @State private var isShowingFolderPicker = false
    
    var body: some View {
            Button {
                isShowingFolderPicker = true
            } label: {
                Label("Import All", systemImage: "square.and.arrow.down.on.square")
            }
            .disabled(collection.isRunning)
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
                        }
                    }
                case .failure(let error):
                    print("Error selecting folder: \(error)")
                }
            }
            .fileDialogConfirmationLabel("Import All") // MacOS
    }
}

#Preview {
    BulkImportView()
}
