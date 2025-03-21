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
    //@Environment(\.modelContext) private var modelContext
    @Query private var notes: [Note]
    @Binding var selectedNote: Note? // Binding or Bindable???
    @Binding var sortOption: SortOption
    @Bindable var config: StorageConfiguration // = StorageConfiguration()

    // Search (Should this be own search view model? Or separate sidebar view?) 
    //@State var searchText = ""
    //@State var isExpanded = false
    //@State var searchType: SearchType = .title
    //@Environment(ExportModel.self) var bulkModel
    
    @Environment(CollectionModel.self) var collection // Prototype querry update receiver.
    @State var count = 0
    
    // The sortDescriptor value is passed separately from sortOption binding, so that re-init and re-query whenever sort descriptor changes. A sortOption change just re-calculates the body (sidebar).
    init(sortDescriptor: SortDescriptor<Note>, sortOption: Binding<SortOption>, config: StorageConfiguration, selection: Binding<Note?> /*, context: ModelContext*/) {
        self._notes = Query(sort: [sortDescriptor]) // Query with sort descriptor
        self._sortOption = sortOption
        self.config = config
        self._selectedNote = selection
    }

    var body: some View {
        
        NavigationSplitView {
            Sidebar(selectedNote: $selectedNote, sortOption: $sortOption, config: config, notes: notes)
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
    //let context = ModelContainer.sharedInMemory.mainContext
    MainView(sortDescriptor: SortOption.titleAZ.sortDescriptor, sortOption: $sortOption, config: config, selection: $selection /*, context: context*/)
}
