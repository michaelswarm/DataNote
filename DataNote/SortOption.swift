//
//  SortOption.swift
//  RecordText
//
//  Created by Michael Swarm on 3/4/25.
//

import Foundation

// Enum for sort options
enum SortOption: CaseIterable, Identifiable {
    case titleAZ, titleZA, modifiedRecent, modifiedOldest
    var id: Self { self }
}

// Locate at point of use: SortOptionPicker (label) and MainView (sort descriptor)???
// Worth effor to separate storage specific logic?
extension SortOption {
    var label: String {
        switch self {
        case .titleAZ:
            "A-Z"
        case .titleZA:
            "Z-A"
        case .modifiedRecent:
            "Recent"
        case .modifiedOldest:
            "Oldest"
        }
    }
    var sortDescriptor: SortDescriptor<Note> {
        switch self {
        case .titleAZ:
            SortDescriptor(\Note.title)
        case .titleZA:
            SortDescriptor(\Note.title, order: .reverse)
        case .modifiedRecent:
            SortDescriptor(\Note.modified, order: .reverse)
        case .modifiedOldest:
            SortDescriptor(\Note.modified)
        }
    }
}
