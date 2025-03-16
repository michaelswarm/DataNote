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
    @Binding private var selectedNote: Note?
    @Binding var sortOption: SortOption
    @Bindable var config: StorageConfiguration // = StorageConfiguration()

    // Search
    @State var searchText = ""
    @State var isExpanded = false
    @State var searchType: SearchType = .title
    @Environment(ExportModel.self) var bulkModel

    // The sortDescriptor value is passed separately from sortOption binding, so that re-init and re-query whenever sort descriptor changes. A sortOption change just re-calculates the body (sidebar).
    init(sortDescriptor: SortDescriptor<Note>, sortOption: Binding<SortOption>, config: StorageConfiguration, selection: Binding<Note?>) {
        self._notes = Query(sort: [sortDescriptor]) // Query with sort descriptor
        self._sortOption = sortOption
        self.config = config
        self._selectedNote = selection
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                SearchBar(isExpanded: $isExpanded, searchText: $searchText, searchType: $searchType)
                Divider()
                
                List(selection: $selectedNote) {
                    if searchText.isEmpty {
                        ForEach(notes) { note in
                            Text(note.title)
                                .tag(note)
                        }
                        .onDelete(perform: deleteNotes) // Does not work with sidebar list style
                    } else {
                        if searchType == .title {
                            ForEach(bulkModel.results, id: \.self) { note in
                                Text(note.title)
                                    .tag(note)
                            }
                        } else if searchType == .content {
                            ForEach(bulkModel.results, id: \.self) { note in
                                Text(note.title)
                                    .tag(note)
                            }
                        }
                    }
                }
                
                // count needs to adjust
                ActionBar(sortOption: $sortOption, config: config, count: searchText.isEmpty ? notes.count : bulkModel.results.count, selection: $selectedNote)
                    .padding(.top, 2)
                    .padding(.bottom, 4)
                    .padding(.horizontal, 8)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItemGroup {
                    Button(action: addNote) {
                        Label("Add Note", systemImage: "plus")
                        // Label("Add Note", systemSymbol: .plus)
                    }
                    Spacer()
                    Button {
                        searchText = "" // Clear search
                        isExpanded.toggle()
                    } label: {
                        Image(systemName: "magnifyingglass")
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
    @Previewable @State var selection: Note? = nil
    ContentView(sortDescriptor: SortOption.titleAZ.sortDescriptor, sortOption: $sortOption, config: config, selection: $selection)
}
