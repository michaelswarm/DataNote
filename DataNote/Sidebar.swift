//
//  Sidebar.swift
//  DataNote
//
//  Created by Michael Swarm on 3/21/25.
//

import SwiftUI
import SwiftData

// NOT USED: Parameters used across sidebar, in search bar, note list and action bar, not just search bar.
struct SearchViewModel {
    var searchText = ""
    var isExpanded = false
    var searchType: SearchType = .title
}

struct Sidebar: View {
    @Binding var selectedNote: Note? // Binding or Bindable???
    @Binding var sortOption: SortOption
    @Bindable var config: StorageConfiguration // = StorageConfiguration()
    var notes: [Note] = [] // This does not work! 
    
    // Search State (Separate search view model? Or do separate parameters make view more flexible?)
    @State var search = SearchViewModel()
    @State var searchText = ""
    @State var isExpanded = false
    @State var searchType: SearchType = .title
    //@Environment(ExportModel.self) var bulkModel
    @Environment(CollectionModel.self) var collection // Prototype querry update receiver.
    @State var count = 0
    
    var body: some View {
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
                        ForEach(collection.results, id: \.self) { note in
                        //ForEach(bulkModel.results, id: \.self) { note in
                            Text(note.title)
                                .tag(note)
                        }
                    } else if searchType == .content {
                        ForEach(collection.results, id: \.self) { note in
                        //ForEach(bulkModel.results, id: \.self) { note in
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
            ActionBar(sortOption: $sortOption, config: config, count: searchText.isEmpty ? notes.count : collection.results.count, selection: $selectedNote)

            //ActionBar(sortOption: $sortOption, config: config, count: searchText.isEmpty ? notes.count : bulkModel.results.count, selection: $selectedNote)
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
    }
}
