//
//  Note.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

import Foundation
import SwiftData

@Model
class Note {
    var title: String
    var content: String
    var creationDate: Date

    init(title: String = "New Note", content: String = "", creationDate: Date = Date()) {
        self.title = title
        self.content = content
        self.creationDate = creationDate
    }
}
