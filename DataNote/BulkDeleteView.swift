//
//  BulkDeleteView.swift
//  RecordText
//
//  Created by Michael Swarm on 3/5/25.
//

import SwiftUI
import SwiftData

struct BulkDeleteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ExportModel.self) var exportModel // If environment, then why init parameter???
    //@Environment(ImportModel.self) var importModel
    //@Environment(DeleteModel.self) var deleteModel
    @State private var showingConfirmation = false
    
    @Bindable var shared: ExportModel
    @Binding var selection: Note?
    init(sharedModel: ExportModel, selection: Binding<Note?>) {
        self.shared = sharedModel
        self._selection = selection
    }

    var body: some View {
        /*if shared.isRunning {
            ProgressBar(progress: $shared.progress) // ProgressView + ProgressModel wrapper
        } else {*/
            Button(role: .destructive) {
                showingConfirmation = true
            } label: {
                Label("Delete All", systemImage: "trash") 
                    .foregroundStyle(.red) 
            }
            .disabled(exportModel.isRunning)
            .confirmationDialog("Are you sure?",
                                isPresented: $showingConfirmation,
                                titleVisibility: .visible) {
                Button("Delete All", role: .destructive) {
                    Task {
                        selection = nil // Clear selection before delete.
                        await shared.deleteAllNotes()
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
        //}
    }    
}

#Preview {
    @Previewable @State var selection: Note?

    var sharedModelContainer: ModelContainer = {
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
    
    BulkDeleteView(sharedModel: shared, selection: $selection)
}
