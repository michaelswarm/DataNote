//
//  SearchType.swift
//  RecordText
//
//  Created by Michael Swarm on 3/9/25.
//

/*
 Used by sidebar.
 
 Potentially used by custom search field. 
 */

import Foundation

enum SearchType: Identifiable, CaseIterable, CustomStringConvertible {
    case title, content
    var id: Self { self }
    var description: String {
        switch self {
        case .title:
            "Title"
        case .content:
            "Content"
        }
    }
}
