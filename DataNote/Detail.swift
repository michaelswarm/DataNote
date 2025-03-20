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
    @Bindable var note: Note
    @Binding var selectedNote: Note?
    let titlesNotSelfSorted: [String]
    
    @Environment(CollectionModel.self) var collection // Prototype querry update receiver.
    
    @State var titleEdit: String // View state does not change on change to bindable.
    init(note: Note, selectedNote: Binding<Note?>, titlesNotSelfSorted: [String]) {
        print("Detail init...")
        self.note = note
        self._selectedNote = selectedNote
        self.titlesNotSelfSorted = titlesNotSelfSorted // Used as parameter to WikiEditor
        self.titleEdit = note.title
        
        print("Titles (not self) count \(titlesNotSelfSorted.count)...")        
    }
    
    var body: some View {
        @Bindable var collection = collection
        
        if let selectedNote = selectedNote {
            
            VStack(alignment: .leading, spacing: 0) {
                TextField("Title", text: $titleEdit)
                    .onSubmit {
                        print("On submit...")
                        // rename
                        let newTitle = titleEdit
                        selectedNote.title = newTitle
                        selectedNote.modifiedNow() // Update modified with title modification.
                    }
                    //.padding(.horizontal, 2) // Horizontal padding to match TextEditor internal horizontal padding for visual space.
                
                let noteContent = Binding(
                    get: { selectedNote.content },
                    set: { selectedNote.update(keyPath: \.content, to: $0) }
                )
                // Collection model
                WikiEditor(text: noteContent, title: $collection.selectedTitle, titlesShortestFirstExcludingSelf: titlesNotSelfSorted, selection: $collection.contentSelection)
                
                    .onChange(of: selectedNote.content) {
                        selectedNote.modifiedNow() // Update modified with content modification.
                    }
                /* Wiki title links debug: May want to add index and history too...
                VStack(alignment: .leading, spacing: 0) {
                    Text("Titles \(collection.titles.count) \(collection.titles)") // sort according to sidebar setting
                    Text("Short First Not Self \(collection.titlesExcludingSelfShortestFirst.count) \(collection.titlesExcludingSelfShortestFirst)")
                }
                .padding(4)*/
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
