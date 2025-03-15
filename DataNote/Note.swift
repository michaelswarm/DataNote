//
//  Note.swift
//  DataNote
//
//  Created by Michael Swarm on 3/13/25.
//

/*
 Property rename or add causes schema migration.
 SwiftData does not support property observers.
 */

import Foundation
import SwiftData

@Model
class Note {
    var title: String /*{
        didSet { // Not supported, workaround use view on change
            modifiedNow()
        }
    }*/
    var content: String /*{
        didSet { // Not supported, workaround use view on change
            modifiedNow()
        }
    }*/
    var created: Date
    var modified: Date // Can not add to production model?

    init(title: String = "New Note", content: String = "", created: Date = Date(), modified: Date = Date()) {
        self.title = title
        self.content = content
        self.created = created
        self.modified = modified
    }
    
    func modifiedNow() {
        modified = .now
    }
    
    /* Property Observer Workaround
     https://www.hackingwithswift.com/quick-start/swiftdata/how-to-create-derived-attributes-with-swiftdata
     Use with calculated binding.
     */
    func update<T>(keyPath: ReferenceWritableKeyPath<Note, T>, to value: T) {
        self[keyPath: keyPath] = value
        modified = .now
    }
}
