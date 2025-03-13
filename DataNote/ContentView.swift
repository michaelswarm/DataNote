//
//  ContentView.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @State private var selectedNote: Note?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedNote) {
                ForEach(notes) { note in
                    Text(note.title)
                        .tag(note)
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Notes")
            .toolbar {
                Button(action: addNote) {
                    Label("Add Note", systemImage: "plus")
                    // Label("Add Note", systemSymbol: .plus)
                }
            }
        } detail: {
            if let selectedNote = selectedNote {
                NoteDetailView(note: selectedNote)
            } else {
                Text("Select a note")
            }
        }
    }
    
    private func addNote() {
        let newNote = Note()
        modelContext.insert(newNote)
        selectedNote = newNote
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(modelContext.delete)
            selectedNote = nil
        }
    }
}

#Preview {
    ContentView()
}
