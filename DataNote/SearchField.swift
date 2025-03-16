//
//  SearchField.swift
//  RecordText
//
//  Created by Michael Swarm on 3/9/25.
//

/*
 Custom text field for search
 - submit action
 - cancel action
 
 Potential to customize style. 
 Potential to customize the search icon for search type.
 */

import SwiftUI

struct SearchField: View {
    @Binding var searchText: String // = ""
    @Binding var searchType: SearchType // = .title
    let submitAction: ()->()
    let cancelAction: ()->()
    
    @State var isExpanded: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            if isExpanded {
                    Picker("Search", selection: $searchType) {
                        ForEach(SearchType.allCases) { option in
                            Text(option.description)
                        }
                    }
                    .focusEffectDisabled()
                    .labelsHidden()
                    .buttonStyle(.accessoryBar)
                    .controlSize(.small)
                    .frame(maxWidth: 70)
            }
        Button {
            isExpanded.toggle()
        } label: {
            Image(systemName: "magnifyingglass")
                .padding(4)
        }
        .buttonStyle(.plain)
        .focusEffectDisabled()
            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
            
                // Submit action and environment makes non-reusable. Use submit action parameter instead???
                .onSubmit {
                    submitAction()
                    /*Task {
                        await contentSearchModel.searchAllNotes()
                    }*/
                }
                .onKeyPress(keys: [.escape]) { press in // 2024-IOS17-MacOS14
                    // print("Received \(press.characters)")
                    isExpanded.toggle()
                    return .handled
                }
                .focusEffectDisabled()
                //.focused($isTextFieldFocused, equals: true)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                    withAnimation {
                        cancelAction()
                        // isExpanded.toggle()
                    }
                    // isTextFieldFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .focusEffectDisabled()
                .buttonStyle(.plain) // no background capsule
                .padding(.horizontal, 4) // plain style needs padding
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6) // Basic rounded rectangle
                .fill(Color.white)
        )
    }
}

// Esc keypress does not work in preview.
#Preview {
    @Previewable @State var searchText: String = ""
    @Previewable @State var searchType: SearchType = .title
    
    SearchField(searchText: $searchText, searchType: $searchType, submitAction: {
        print("Submit action...")
    }, cancelAction: {
        print("Cancel action...")
    } )
    .buttonStyle(.accessoryBar)
    .padding()
    .frame(width: 200, height: 100)
}
