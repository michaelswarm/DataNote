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
    @Query private var notes: [Note]
    @Binding var selectedNote: Note? // Binding or Bindable???
    @Binding var sortOption: SortOption
    @Bindable var config: StorageConfiguration // = StorageConfiguration()

    @Environment(CollectionModel.self) var collection // Prototype querry update receiver.
    @State var count = 0
    
    // The sortDescriptor value is passed separately from sortOption binding, so that re-init and re-query whenever sort descriptor changes. A sortOption change just re-calculates the body (sidebar).
    init(sortDescriptor: SortDescriptor<Note>, sortOption: Binding<SortOption>, config: StorageConfiguration, selection: Binding<Note?>) {
        self._notes = Query(sort: [sortDescriptor]) // Query with sort descriptor
        self._sortOption = sortOption
        self.config = config
        self._selectedNote = selection
    }

    var body: some View {
        
        NavigationSplitView {
            Sidebar(notes: notes, selectedNote: $selectedNote, sortOption: $sortOption, config: config)
        } detail: {
            if let selectedNote = selectedNote {
                
                // Passes collection titlesExcludedSelfSorted as parameter.
                Detail(note: selectedNote, selectedNote: $selectedNote, titlesNotSelfSorted: collection.titlesExcludingSelfShortestFirst) // Can even move this up one level, since Detail handles selected note optional. Detail needs to write to selected note.
                // NoteDetailView(note: selectedNote) // NOT USED: FULLY MIGRATED TO Detail

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
    MainView(sortDescriptor: SortOption.titleAZ.sortDescriptor, sortOption: $sortOption, config: config, selection: $selection)
}
