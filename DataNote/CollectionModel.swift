//
//  CollectionModel.swift
//  DataNote
//
//  Created by Michael Swarm on 3/19/25.
//

/*
 Prototype to connect SwiftData model to view query updates.
 Create in app. Pass by environment.
 Connect to top level view query update with on change and on appear. 
 Receive via receive update function.
 Send via observation to other interested parties.
 Verify with print statements.
 
 In theory also possible to list to Notification Center messages, but not working in practice yet.
 
 Model probably needs context for any operations.
 
 Possible to consolidate bulk operations and wiki operations into single model?
 
 Use as main model?
 Use as wiki model?
 */

// Sync Algorithm: title and note
// In this model, selectedTitle and selectedNote
/*var title: String? = nil {
    didSet {
        if title != oldValue {
            note = resolveNote(from: title)
        }
    }
}
var note: Note? = nil {
    didSet {
        if note != oldValue {
            title = note?.title
        }
    }
}*/

import Foundation
import SwiftData

@Observable
@MainActor
class CollectionModel {
    var notes: [Note] = []
    var count = 0
    
    func receiveUpdate(notes: [Note]) {
        print("Collection model receive update \(count)...")
        self.notes = notes
        count = count + 1
        
        /* not used - optimization
        titlesCache = titles
        titlesNotSelfSortedCache = titlesExcludingSelfShortestFirst*/
    }
    var context: ModelContext {
        ModelContainer.shared.mainContext
    }
    
    // MARK: Main Model
    // Title and note MUST be kept in sync (wiki exclude self).
    // Avoid circular sync with check if newValue != oldValue
    var selectedNote: Note? { // Move into wiki model???
        didSet {
            if selectedNote != oldValue {
                selectedTitle = selectedNote?.title
            }
            contentSelection = NSRange(location: 0, length: 0) // Start edit at top, not bottom.
        }
    }
    
    func addNote() {
        let newNote = Note()
        context.insert(newNote)
        try? context.save()
        selectedNote = newNote // select after insert
        //wiki.updateTitles()
    }

    func deleteNotes(offsets: IndexSet) {
        offsets.map { notes[$0] }
            .forEach { note in
                if selectedNote != nil { // unselect only if note is selected
                    selectedNote = nil // unselect before delete
                }
                context.delete(note)
                try? context.save()
            }
        //wiki.updateTitles()
    }
    
    // MARK: Lazy Init Singleton
    static var shared: CollectionModel = { return CollectionModel() }()

    // MARK: Wiki Model
    var selectedTitle: String? {
        didSet {
            if selectedTitle != oldValue {
                selectedNote = resolveNote(from: selectedTitle)
            }
            contentSelection = NSRange(location: 0,length: 0)
        }
    }
    
    var contentSelection: NSRange = NSRange(location: 0,length: 0) // TBD: Optionally used for add title or scroll to content selection...
    
    // Calculated Values
    // Up to client views to pull and re-calculate titles.
    var titles: [String] { notes.map(\.title) } // more stable than titlesExcludingSelf, only changes on add, delete and rename
    var titlesExcludingSelf: [String] { // changes on detail change, which is frequent
        if let selectedTitle = selectedTitle {
            var set = Set(titles)
            if let removed = set.remove(selectedTitle) {
                return Array(set)
            } else {
                return []
            }
        } else {
            print("Error titles excluding self without valid title selection...")
            return titles // bug fix ??? originally returned [], never called from detail without selection
        }
    }
    var titlesExcludingSelfShortestFirst: [String] {
        titlesExcludingSelf.sorted { $0.count < $1.count } // Sorted by length, shortest to longest, not alphabet
    }
    
    func resolveNote(from title: String?) -> Note? {
        guard let title = title else { return nil }
        
        if let index = notes.firstIndex(where: { $0.title == title }) {
            let note = notes[index]
            return note
        } else {
            print("ResolveNote: Can not find index...")
            return nil
        }
    }

    /* not used - optimization 
    // Cached Values (optimization, avoid calculation each time needed)
    // Not every update may require re-calculation of titles. Only add, delete and rename. Not content or attribute changes.
    var titlesCache: [String] = [] // more stable
    var titlesNotSelfSortedCache: [String] = [] // less stable
    
    func updateTitles() {
        titlesCache = titles
        titlesNotSelfSortedCache = titlesExcludingSelfShortestFirst
    }*/
}
