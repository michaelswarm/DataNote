//
//  NoteDetailView.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

import Foundation
import SwiftUI

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var note: Note

    var body: some View {
        VStack {
            TextField("Title", text: $note.title)
                .font(.title)
                .padding()
            TextEditor(text: $note.content)
                .padding()
        }
        .navigationTitle("Note Details")
    }
}
