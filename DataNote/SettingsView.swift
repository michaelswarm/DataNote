//
//  SettingsView.swift
//  DataNote
//
//  Created by Michael Swarm on 3/15/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var sortOption: SortOption // = .titleAZ
    @Bindable var config: StorageConfiguration // = StorageConfiguration()

    var body: some View {
        TabView {
            SortSettingsView(sortOption: $sortOption)
                .tabItem {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            StorageSettingsView(config: config)
                .tabItem {
                    Label("Storage", systemImage: "archivebox")
                }

        }
    }
}

#Preview {
    @Previewable @State var sortOption: SortOption = .titleAZ
    @Previewable @State var config: StorageConfiguration = StorageConfiguration()
    SettingsView(sortOption: $sortOption, config: config)
}
