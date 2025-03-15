//
//  StorageSettingsView.swift
//  RecordText
//
//  Created by Michael Swarm on 3/5/25.
//

import SwiftUI

@Observable
class StorageConfiguration {
    var showExportAll = true
    var showImportAll = true
    var showDeleteAll = false
}
struct StorageSettingsView: View {
    @Bindable var config: StorageConfiguration

    var body: some View {
        Form {
            Section(header: Text("Filesystem")) {
                LabeledContent("Export All") {
                    Toggle("", isOn: $config.showExportAll)
                        .labelsHidden()
                }
                LabeledContent("Import All") {
                    Toggle("", isOn: $config.showImportAll)
                        .labelsHidden()
                }
            }
            
            Section(header: Text("Database")) {
                LabeledContent("Delete All") {
                    Toggle("", isOn: $config.showDeleteAll)
                        .labelsHidden()
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Configuration")
    }
}

#Preview {
    @Previewable @State var config = StorageConfiguration()
    StorageSettingsView(config: config)
        .padding()
        .frame(width: 400, height: 300, alignment: .topLeading)
}
