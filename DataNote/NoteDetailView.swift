//
//  NoteDetailView.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

import Foundation
import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var note: Note
    
    init(note: Note) { // Re-init on note selection change, not just binding update. (On change should not trigger on selection change.)
        self.note = note
        print("Detail.init...")
    }

    var body: some View {
        let noteContent = Binding(
            get: { note.content },
            set: { note.update(keyPath: \.content, to: $0) }
        )
        let noteTitle = Binding(
            get: { note.title },
            set: { note.update(keyPath: \.title, to: $0) }
        )
        
        VStack(spacing: 0) {
            TextField("Title", text: noteTitle) // $note.title
                //.font(.title)
                //.padding()
                /*.onChange(of: note.title) { oldValue, newValue in
                    note.modifiedNow()
                }*/ 
            Divider()
            TextEditor(text: noteContent) // $note.content
                .font(.body)
                //.padding()
                /*.onChange(of: note.content) { oldValue, newValue in // Also triggers on open, not just edit.
                    print("OnChange of note.content...")
                    if oldValue != newValue {
                        print("old value != new value...") // <-- on init
                    } else {
                        print("old value = new value...")
                    }
                    note.modifiedNow()
                }*/
            // Divider()
            // NoteInfoBar???
            HStack {
                Text("Created at \(note.created.formatted())")
                Spacer()
                Text("Modified at \(note.modified.formatted())")
            }
            .padding(4)
        }
        .navigationTitle("Note Details")
    }
}
