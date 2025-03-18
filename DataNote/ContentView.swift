//
//  ContentView.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

import SwiftUI
import SwiftData
import WikiEditor

// MainView
struct ContentView: View {
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
    @Environment(WikiModel.self) var wiki // Replace local wiki with app wiki
    
    // @State var wiki: WikiModel
    // Wiki Model (depends of query, update? performance-scale?) Can model update be driven by view on change???
    /*@State var selectedTitle: String?
    @State var contentSelection: NSRange = NSRange(location: 0,length: 0) // TBD: Optionally used for add title or scroll to content selection...
    var titles: [String] { notes.map(\.title) }
    var titlesExcludingSelf: [String] {
        if let selectedTitle = selectedTitle {
            var set = Set(titles)
            if let removed = set.remove(selectedTitle) {
                return Array(set)
            } else {
                return []
            }
        } else {
            return []
        }
    }
    var titlesExcludingSelfSorted: [String] {
        titlesExcludingSelf.sorted { $0.count < $1.count }
    }
    @State var titlesNotSelfSorted: [String] = [] // Pass to WikiEditor. Must be updated, along with selectedTitle.
    func resolveNote(from title: String?) -> Note? {
        guard let title = title else { return nil }
        
        if let index = notes.firstIndex(where: { $0.title == title }) {
            let note = notes[index]
            return note
        } else {
            print("ResolveNote: Can not find index...")
            return nil
        }
    }*/

    // The sortDescriptor value is passed separately from sortOption binding, so that re-init and re-query whenever sort descriptor changes. A sortOption change just re-calculates the body (sidebar).
    init(sortDescriptor: SortDescriptor<Note>, sortOption: Binding<SortOption>, config: StorageConfiguration, selection: Binding<Note?>, context: ModelContext) {
        self._notes = Query(sort: [sortDescriptor]) // Query with sort descriptor
        self._sortOption = sortOption
        self.config = config
        self._selectedNote = selection
        
        // self.wiki = WikiModel(modelContext: context)
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
                Detail(wiki: wiki, note: selectedNote, selectedNote: $selectedNote, titlesNotSelfSorted: wiki.titlesNotSelfSorted) // Can even move this up one level, since Detail handles selected note optional. Detail needs to write to selected note.
                // NoteDetailView(note: selectedNote)

            } else {
                Text("Select a note")
            }
        }
    }
    
    private func addNote() {
        let newNote = Note()
        modelContext.insert(newNote)
        selectedNote = newNote
        wiki.updateTitles()
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(modelContext.delete)
            selectedNote = nil
        }
        wiki.updateTitles()
    }
}

#Preview {
    @Previewable @State var sortOption = SortOption.titleAZ
    @Previewable @State var config: StorageConfiguration = StorageConfiguration()
    @Previewable @State var selection: Note? = nil
    let context = ModelContainer.shared.mainContext
    ContentView(sortDescriptor: SortOption.titleAZ.sortDescriptor, sortOption: $sortOption, config: config, selection: $selection, context: context)
}
