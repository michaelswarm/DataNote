//
//  SortSettingsView.swift
//  DataNote
//
//  Created by Michael Swarm on 3/14/25.
//

import SwiftUI

struct SortSettingsView: View {
    @Binding var sortOption: SortOption

    var body: some View {
        Form {
            LabeledContent("Sort") {
                SortOptionPicker(sortOption: $sortOption)
                    .labelsHidden()
            }
        }
            .formStyle(.grouped)
            .navigationTitle("Sort")

            // Apply padding and frame here, or at caller (both RecordTextApp and MainView)?
            //.padding()
            //.frame(width: 400, height: 300, alignment: .topLeading)
    }
}

#Preview {
    SortSettingsView(sortOption: .constant(.titleAZ))
}
