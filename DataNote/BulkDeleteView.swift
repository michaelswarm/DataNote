//
//  BulkDeleteView.swift
//  RecordText
//
//  Created by Michael Swarm on 3/5/25.
//

import SwiftUI
import SwiftData

struct BulkDeleteView: View {
    @Binding var selection: Note?
    @Environment(CollectionModel.self) var collection

    @State private var showingConfirmation = false
    
    init(selection: Binding<Note?>) {
        self._selection = selection
    }
    
    var body: some View {
        Button(role: .destructive) {
            showingConfirmation = true
        } label: {
            Label("Delete All", systemImage: "trash")
                .foregroundStyle(.red)
        }
        .disabled(collection.isRunning)
        .confirmationDialog("Are you sure?",
                            isPresented: $showingConfirmation,
                            titleVisibility: .visible) {
            Button("Delete All", role: .destructive) {
                Task {
                    selection = nil // Clear selection before delete.
                    await collection.deleteAllNotes()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    @Previewable @State var selection: Note?
    BulkDeleteView(selection: $selection)
}
