//
//  SortOptionPicker.swift
//  RecordText
//
//  Created by Michael Swarm on 3/4/25.
//

import SwiftUI

/*
 Keep logic of label and sort descriptor in the enum itself, not the view.
 */

struct SortOptionPicker: View {
    @Binding var sortOption: SortOption // = .titleAZ
    
    var body: some View {
        Picker("Sort", selection: $sortOption) {
            ForEach(SortOption.allCases) { option in
                Text(option.label)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    SortOptionPicker(sortOption: .constant(.titleAZ))
}
