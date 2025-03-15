//
//  ContentView.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

import SwiftUI
import SwiftData

// MainView
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @State private var selectedNote: Note?
    @Binding var sortOption: SortOption
    @Bindable var config: StorageConfiguration // = StorageConfiguration()
    
    // The sortDescriptor value is passed separately from sortOption binding, so that re-init and re-query whenever sort descriptor changes. A sortOption change just re-calculates the body (sidebar).
    init(sortDescriptor: SortDescriptor<Note>, sortOption: Binding<SortOption>, config: StorageConfiguration) {
        self._notes = Query(sort: [sortDescriptor]) // Query with sort descriptor
        self._sortOption = sortOption
        self.config = config
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(selection: $selectedNote) {
                    ForEach(notes) { note in
                        Text(note.title)
                            .tag(note)
                    }
                    .onDelete(perform: deleteNotes)
                }
                ActionBar(sortOption: $sortOption, config: config, count: notes.count, selection: $selectedNote)
                    .padding(.top, 2)
                    .padding(.bottom, 4)
                    .padding(.horizontal, 8)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItemGroup {
                    Spacer()
                    Button(action: addNote) {
                        Label("Add Note", systemImage: "plus")
                        // Label("Add Note", systemSymbol: .plus)
                    }
                }
            }
            #if os(macOS)
                    .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            #endif
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
    @Previewable @State var sortOption = SortOption.titleAZ
    @Previewable @State var config: StorageConfiguration = StorageConfiguration()
    ContentView(sortDescriptor: SortOption.titleAZ.sortDescriptor, sortOption: $sortOption, config: config)
}
