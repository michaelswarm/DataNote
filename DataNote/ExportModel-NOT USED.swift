//
//  ExportModel.swift
//  RecordText
//
//  Created by Michael Swarm on 3/5/25.
//
/*
import Foundation
import SwiftData
import UniformTypeIdentifiers

@Observable
@MainActor
// BulkOperationModel???
class ExportModel {
    let modelContext: ModelContext
    var isRunning = false
    var progress = ProgressModel() // Display by ProgressView

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Function to fetch data (same for export model and import model) 
    func fetchRecords(predicate: Predicate<Note>? = nil, sortDescriptors: [SortDescriptor<Note>]) throws -> [Note] {
        let fetchDescriptor = FetchDescriptor<Note>(predicate: predicate, sortBy: sortDescriptors)
        return try modelContext.fetch(fetchDescriptor)
    }
    
    // MARK: IMPORT

    func exportAllFiles(to folderURL: URL) async {
        print("ExportAllFiles from \(folderURL.absoluteString)...")
        isRunning = true
        progress = ProgressModel()
        progress.message = "Preparing export..."

        var notes = [Note]()
        if let records = try? fetchRecords(predicate: #Predicate<Note> { record in true }, sortDescriptors: [SortDescriptor(\.title)]) {
            notes = records
            progress.total = notes.count
        }
        
        // Filesystem access outside the sandbox requires wrap with start-stop access security scope resource.
        // Resource is export folder URL, not file URL.
        // Start accessing the security-scoped resource
        if folderURL.startAccessingSecurityScopedResource() {
            // Import loop
            for (index, note) in notes.enumerated() {
                await exportNote(note, to: folderURL)
            }
            // Stop accessing the resource after the action is complete
            folderURL.stopAccessingSecurityScopedResource()
        } else {
            print("Failed to start accessing security-scoped resource.")
        }
        
        progress.message = "Export complete!"
        isRunning = false
    }
    
    // Precondition start security scope resource access to folderURL
    // Otherwise, no file access outside sandbox, even with App Sandbox permissions.
    private func exportNote(_ note: Note, to folderURL: URL) async {
        let fileName = note.title + "." + UTType.plainText.preferredFilenameExtension! // ok for plaintext
        let fileURL = folderURL.appendingPathComponent(fileName)
        let fileManager = FileManager.default

        do {
            try note.content.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Write file \(fileURL.absoluteString)...")
            try fileManager.setAttributes([.creationDate: note.created, .modificationDate: note.modified], ofItemAtPath: fileURL.path)
            print("Write file attributee \(fileURL.absoluteString)...")

            // Needed to see and debug progress view, otherwise too fast to see.
            // try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds (Too fast to debug-test for small counts.)
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds (??? to debug-test for small counts.)
            // try await Task.sleep(nanoseconds: 1_000_000_000) // 1.0 seconds (Good to debug-test small counts.)

            progress.completed += 1
            progress.message = "Exporting \(progress.formattedCompletedOfTotal), time remaining \(progress.formattedRemainingTime)"

        } catch {
            print("Error exporting \(note.title): \(error.localizedDescription)...")
                progress.message = "Error exporting \(note.title): \(error.localizedDescription)"
        }
    }
    
    // MARK: EXPORT
    
    func getFileDates(from fileURL: URL) -> (creationDate: Date?, modificationDate: Date?) {
        let fileManager = FileManager.default
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            
            let creationDate = attributes[.creationDate] as? Date
            let modificationDate = attributes[.modificationDate] as? Date
            
            return (creationDate, modificationDate)
            
        } catch {
            print("Error getting file attributes: \(error)")
            return (nil, nil)
        }
    }
    
    func importAllFiles(from folderURL: URL) async {
        print("ImportAllFiles from \(folderURL.absoluteString)...")
        isRunning = true
        progress = ProgressModel()
        progress.message = "Preparing import..."

        // Filesystem access outside the sandbox requires wrap with start-stop access security scope resource.
        // Resource is export folder URL, not file URL.
        // Start accessing the security-scoped resource
        if folderURL.startAccessingSecurityScopedResource() {
            
            // Import loop
            let fileManager = FileManager.default
            do {
                // Might want to filter based on UTType instead???
                let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                    .filter { $0.pathExtension == "txt" }
                progress.total = fileURLs.count
                
                // Import loop
                for (index, fileURL) in fileURLs.enumerated() {
                    await importFile(fileURL)
                }
                
            } catch {
                print("Error reading folder: \(error)")
                isRunning = false
            }
            
            // Stop accessing the resource after the action is complete
            folderURL.stopAccessingSecurityScopedResource()
        } else {
            print("Failed to start accessing security-scoped resource.")
        }
        
        progress.message = "Import complete!"
        isRunning = false
    }
    
    private func importFile(_ fileURL: URL) async {
        do {
            // Read-Decode-Attributes
            let title = fileURL.deletingPathExtension().lastPathComponent
            let content = try String(contentsOf: fileURL, encoding: .utf8) // Only thrown error comes from here. Might want to separate into separate read and decode steps, for better error resolution?
            let fileDates = getFileDates(from: fileURL)
            
            // Make Note
            let note = Note(title: title, content: content, created: fileDates.creationDate ?? .now, modified: fileDates.modificationDate ?? .now)
            
            // Insert Note
            modelContext.insert(note)
            try? modelContext.save()
            // Needed to see and debug progress view, otherwise too fast to see.
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1.0 seconds // 0.1 seconds

            progress.completed += 1
            progress.message = "Importing \(progress.formattedCompletedOfTotal), time remaining \(progress.formattedRemainingTime)"
        } catch {
            print("Error importing file \(fileURL): \(error)") // Error reading-decoding utf8 file
        }
    }
    
    // MARK: DELETE
    func deleteAllNotes() async {
        isRunning = true
        progress = ProgressModel()
        progress.message = "Preparing delete..."
        
        var notes = [Note]()
        if let records = try? fetchRecords(predicate: #Predicate<Note> { record in true }, sortDescriptors: [SortDescriptor(\.title)]) {
            notes = records
            progress.total = notes.count
        }
        
        for note in notes {
            await deleteNote(note)
        }
        progress.message = "Delete complete!"
        isRunning = false
    }

    private func deleteNote(_ note: Note) async {
        modelContext.delete(note)
        try? modelContext.save()
        // Artificially slow operation, to visualize for debug and testing progress view. Slow for animation?
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1.0 seconds // 0.1 seconds

        progress.completed += 1
        progress.message = "Deleting \(progress.formattedCompletedOfTotal), time remaining \(progress.formattedRemainingTime)" // Display by ProgressView
    }
    
    // MARK: SEARCH
    // var searchText: String = ""
    var results: [Note] = []
    
    func searchAllNotes(titleText searchText: String) async {
        print("SearchAllNotes for \(searchText)...")
                results = []
        isRunning = true
        progress = ProgressModel()
        progress.message = "Preparing title search..."

        if let notes = try? fetchRecords(predicate: #Predicate<Note> { record in record.title.localizedStandardContains(searchText) }, sortDescriptors: [SortDescriptor(\.title)]) {
            print("Notes \(notes.count)")
            results = notes
            progress.total = results.count
        }

        progress.message = "Title search complete!"
        isRunning = false
    }

    func searchAllNotes(contentText searchText: String) async {
        print("SearchAllNotes for \(searchText)...")
        //results = []
        isRunning = true
        progress = ProgressModel()
        progress.message = "Preparing content search..."
                
        var notes = [Note]()
        // Notice that title search might be handled by a predicate?
        // { record.title.lowercase.contains(searchText.lowercase) }
        if let records = try? fetchRecords(predicate: #Predicate<Note> { record in true }, sortDescriptors: [SortDescriptor(\.title)]) {
            notes = records
            progress.total = notes.count
        }
        
        for note in notes {
            if await matchNote(note, searchText: searchText) {
                results.append(note)
            }
        }
        progress.message = "Conent search complete!"
        isRunning = false
    }
    
    private func matchNote(_ note: Note, searchText: String) async -> Bool {
        var result: Bool = false
        result = note.content.lowercased().contains(searchText) // Don't care how many match, nor case, nor whole word.
        // Artificially slow operation, to visualize for debug and testing progress view. Slow for animation?
        // try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds (Too fast to debug-test for small counts.)
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds (??? to debug-test for small counts.)
        // try? await Task.sleep(nanoseconds: 1_000_000_000) // 1.0 seconds (Good to debug-test small counts.)

        // Progress Update
        progress.completed += 1
        progress.message = "Searching \(progress.formattedCompletedOfTotal), time remaining \(progress.formattedRemainingTime)" // Display by ProgressView
        
        return result
    }
}
*/
