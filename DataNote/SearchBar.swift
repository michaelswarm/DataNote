//
//  SearchBar.swift
//  RecordText
//
//  Created by Michael Swarm on 3/10/25.
//

/*
 Extracted from Sidebar.
 */

import SwiftUI
import SwiftData

struct SearchBar: View {
    @Binding var isExpanded: Bool // = false
    @Binding var searchText: String // = ""
    @Binding var searchType: SearchType // = .title
    //@Environment(\.modelContext) private var modelContext
    @Environment(CollectionModel.self) var collection
    
    private var didSavePublisher: NotificationCenter.Publisher { // Use to refresh search results?
        NotificationCenter.default
            .publisher(for: ModelContext.willSave, object: ModelContainer.shared.mainContext)
    }

    var body: some View {
        if isExpanded {
            SearchField(searchText: $searchText, searchType: $searchType, submitAction: {
                switch searchType {
                case .title:
                    Task {
                        await collection.searchAllNotes(titleText: searchText)
                    }
                case .content:
                    Task {
                        await collection.searchAllNotes(contentText: searchText)
                    }
                }
            }, cancelAction: {
                searchText = ""
                collection.results = []
            })
            .onReceive(didSavePublisher) { _ in
                print("OnReceive didSavePublisher...")
                if !searchText.isEmpty {
                    print("Database change while search active, update search results...")
                    switch searchType {
                    case .title:
                        Task {
                            await collection.searchAllNotes(titleText: searchText)
                        }
                    case .content:
                        Task {
                            await collection.searchAllNotes(contentText: searchText)
                        }
                    }
                }
            }
        }
    }
}

/*#Preview {
    SearchBar()
}*/
