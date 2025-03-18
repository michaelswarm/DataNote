//
//  WikiModel.swift
//  DataNote
//
//  Created by Michael Swarm on 3/17/25.
//

import Foundation
import SwiftData

@Observable
class WikiModel {
    let modelContext: ModelContext
    var notes: [Note] = []
    
    // Move selection into wiki model, so property observer can exclude title. 
    var selection: Note? { // Move into wiki model???
        didSet {
            print("WikiModel selection did set...")
            if let selection = selection {
                exclude(title: selection.title)
            }
            contentSelection = NSRange(location: 0, length: 0) // Start edit at top, not bottom.
        }
    }
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        // Constant and not integrated with add-delete-rename. 
        if let records = try? fetchRecords(predicate: #Predicate<Note> { record in true }, sortDescriptors: [SortDescriptor(\.title)]) {
            notes = records
            titlesNotSelfSorted = titles.sorted()
        }
    }

    // Function to fetch data (same for export model and import model)
    func fetchRecords(predicate: Predicate<Note>? = nil, sortDescriptors: [SortDescriptor<Note>]) throws -> [Note] {
        let fetchDescriptor = FetchDescriptor<Note>(predicate: predicate, sortBy: sortDescriptors)
        return try modelContext.fetch(fetchDescriptor)
    }
    
    // Wiki Model (depends of query, update? performance-scale?) Can model update be driven by view on change???
    var selectedTitle: String? {
        didSet {
            if let selectedTitle = selectedTitle {
                print("UPDATE SELECTED TITLE \(selectedTitle)...")
                /*titlesNotSelfSorted = titlesExcludingSelfSorted // calculates titles excluding self (not self), then sorts
                if titlesNotSelfSorted.contains(selectedTitle) {
                    print("ERROR: DID NOT CALCULATE CORRECTLY!!!...")
                }*/
            } else {
                print("Selected title nil...")
            }
            contentSelection = NSRange(location: 0,length: 0)
        }
    }
    var contentSelection: NSRange = NSRange(location: 0,length: 0) // TBD: Optionally used for add title or scroll to content selection...
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
    var titlesNotSelfSorted: [String] = [] // Pass to WikiEditor. Must be updated, along with selectedTitle.
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
    
    // Called on rename, add, delete
    func updateTitles() {
        if let records = try? fetchRecords(predicate: #Predicate<Note> { record in true }, sortDescriptors: [SortDescriptor(\.title)]) {
            notes = records
            titlesNotSelfSorted = titles.sorted()
        }
    }
    func exclude(title: String) {
        let titles = notes.map(\.title)
        var set = Set(titles)
        print("Titles count \(set.count)...")
        if let _ = set.remove(title) {
            print("Remove title \(title)...")
            let titlesNotSelf = Array(set)
            let titlesNotSelfSorted = titlesNotSelf.sorted { $0.count < $1.count }
            self.titlesNotSelfSorted = titlesNotSelfSorted
            print("Titles not self count \(self.titlesNotSelfSorted.count)...")
        } else {
            print("Not found \(title) in titles...")
        }
    }
}
