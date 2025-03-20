//
//  MainView.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

import SwiftUI
import SwiftData
import WikiEditor

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @Binding var selectedNote: Note? // Binding or Bindable???
    @Binding var sortOption: SortOption
    @Bindable var config: StorageConfiguration // = StorageConfiguration()

    // Search
    @State var searchText = ""
    @State var isExpanded = false
    @State var searchType: SearchType = .title
    @Environment(ExportModel.self) var bulkModel
    @Environment(CollectionModel.self) var collection // Prototype querry update receiver.
    @State var count = 0
    
    // The sortDescriptor value is passed separately from sortOption binding, so that re-init and re-query whenever sort descriptor changes. A sortOption change just re-calculates the body (sidebar).
    init(sortDescriptor: SortDescriptor<Note>, sortOption: Binding<SortOption>, config: StorageConfiguration, selection: Binding<Note?>, context: ModelContext) {
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
                        .onDelete { offsets in // Does not work with sidebar list style
                            withAnimation {
                                collection.deleteNotes(offsets: offsets)
                            }
                        }
                        //.onDelete(perform: collection.deleteNotes) // Does not work with sidebar list style
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
                // Calculate because of note selection
                    .onChange(of: selectedNote) { oldValue, newValue in
                        print("List on change selected note...") // Avoid trigger based on changes to note content???
                        // wiki.contentSelection = NSRange(location: 0, length: 0) // Start edit at top, not bottom. 
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
                    Button(action: collection.addNote) {
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
                
                // Passes collection titlesExcludedSelfSorted as parameter.
                Detail(note: selectedNote, selectedNote: $selectedNote, titlesNotSelfSorted: collection.titlesExcludingSelfShortestFirst) // Can even move this up one level, since Detail handles selected note optional. Detail needs to write to selected note.
                // NoteDetailView(note: selectedNote)

            } else {
                Text("Select a note")
            }
        }
        .onAppear {
            print("Content view appear update \(count)...")
            collection.receiveUpdate(notes: notes) // send update...
        }
        .onChange(of: notes) { newValue, oldValue in
            print("Content view query update \(count)...")
            collection.receiveUpdate(notes: notes) // send update...
        }
    }    
}

#Preview {
    @Previewable @State var sortOption = SortOption.titleAZ
    @Previewable @State var config: StorageConfiguration = StorageConfiguration()
    @Previewable @State var selection: Note? = nil
    let context = ModelContainer.sharedInMemory.mainContext
    MainView(sortDescriptor: SortOption.titleAZ.sortDescriptor, sortOption: $sortOption, config: config, selection: $selection, context: context)
}
