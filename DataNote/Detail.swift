//
//  Detail.swift
//  DataNote
//
//  Created by Michael Swarm on 3/17/25.
//

import SwiftUI
import SwiftData
import WikiEditor

struct Detail: View {
    @Bindable var wiki: WikiModel
    @Bindable var note: Note
    @Binding var selectedNote: Note?
    let titlesNotSelfSorted: [String]
    
    @State var titleEdit: String // View state does not change on change to bindable.
    init(wiki: WikiModel, note: Note, selectedNote: Binding<Note?>, titlesNotSelfSorted: [String]) {
        print("Detail init...")
        self.wiki = wiki
        self.note = note
        self._selectedNote = selectedNote
        self.titlesNotSelfSorted = titlesNotSelfSorted // Used as parameter to WikiEditor
        self.titleEdit = note.title
        
        print("Detail titles count \(titlesNotSelfSorted.count)...")
        print("Detail wiki titles count \(wiki.titlesNotSelfSorted.count)...")
        
        // Do not update wiki from within Detail.init, because it causes infinite loop...
        // self.wiki.exclude(title: note.title) // Recalculates titlesNotSelfSorted to exclude self... (CAUSES CRASH, even if not used)
    }
    
    var body: some View {
        if let selectedNote = selectedNote {
            
            VStack(spacing: 0) {
                TextField("Title", text: $titleEdit)
                    .onSubmit {
                        print("On submit...")
                        // rename
                        selectedNote.title = titleEdit
                        selectedNote.modifiedNow() // Update modified with title modification.
                        wiki.updateTitles()
                    }
                    .padding(.horizontal, 2) // Horizontal padding to match TextEditor internal horizontal padding for visual space.
                
                let noteContent = Binding(
                    get: { selectedNote.content },
                    set: { selectedNote.update(keyPath: \.content, to: $0) }
                )
                WikiEditor(text: noteContent, title: $wiki.selectedTitle, titlesShortestFirstExcludingSelf: titlesNotSelfSorted, selection: $wiki.contentSelection)
                // Calculate because of link
                // Actually triggers every time, after note selection too.
                    .onChange(of: wiki.selectedTitle) { oldValue, newValue in
                        print("On link change selected title...") // Avoid trigger based on changes to note content.
                        self.selectedNote = wiki.resolveNote(from: newValue) // After update, before value changes.
                    }
                    .onChange(of: selectedNote.content) {
                        selectedNote.modifiedNow() // Update modified with content modification.
                    }
                
                HStack {
                    Text("Created at \(note.created.formatted())")
                    Spacer()
                    Text("Modified at \(note.modified.formatted())")
                }
                .padding(4) // Horizontal padding to match TextEditor internal horizontal padding, vertical padding for visual space.
            }
            // This seems to work to monitor change of item, and set view state based on new item.
            .onChange(of: note) { oldItem, newItem in
                print("\(oldItem), \(newItem)")
                // Should item change commit and unsubmitted title edits? For now, leave as is. Don't commit unsubmitted title edits.
                // Can not just call rename, without being specific about which item to rename, oldItem or newItem, and NOT to change selection.
                // Should not override user selection change.
                if titleEdit != oldItem.title {
                    print("Unsubmitted title edit")
                }
                // init equivalent
                titleEdit = newItem.title
            }
            
        } else {
            Text("Select a note")
        }
    }
}

/*#Preview {
 Detail()
 }*/
