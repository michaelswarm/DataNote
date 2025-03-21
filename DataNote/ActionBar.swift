//
//  ActionBar.swift
//  DataNote
//
//  Created by Michael Swarm on 3/14/25.
//

import SwiftUI

struct ActionBar: View {
    @Binding var sortOption: SortOption
    @Bindable var config: StorageConfiguration // = StorageConfiguration()
    let count: Int
    @Binding var selection: Note?
    @State var showSettings = false
    
    //@Environment(ExportModel.self) var exportModel
    @Environment(CollectionModel.self) var collection


    var body: some View {
        //@Bindable var exportModel = exportModel
        @Bindable var collection = collection

        VStack {
            // OperationBar???
            if collection.isRunning {
            //if exportModel.isRunning {
                ProgressBar(progress: $collection.progress) // ProgressView + ProgressModel wrapper
                //ProgressBar(progress: $exportModel.progress) // ProgressView + ProgressModel wrapper
                    .labelStyle(.iconOnly)
                    //.buttonStyle(.accessoryBar)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
            }

            // ActionBar
            HStack {
                
    //#if os(iOS)
                Button {
                    showSettings.toggle()
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .popover(isPresented: self.$showSettings, arrowEdge: .bottom) {
                    SettingsView(sortOption: $sortOption, config: config)
                     //.environment(main)
                    
                    /*TabView {
                        SortSettingsView(sortOption: $sortOption)
                            .tabItem {
                                Label("Settings", systemImage: "gearshape") // Title only within Popup TabView
                            }
                    }*/
                    .padding()
                    .frame(width: 400, height: 350) // Should be at least size of child views, plus height for tab header
                }
    //#endif
                
                Text("Count \(count)")
                Spacer()
                
                if config.showExportAll {
                    BulkExportView()
                    // BulkExportView(sharedModel: collection) // ExportProgressView???
                    // BulkExportView(sharedModel: exportModel) // ExportProgressView???
                    //.buttonStyle(.accessoryBar)
                        //.padding(.vertical, 4)
                        //.padding(.horizontal, 8)
                }
                if config.showImportAll {
                    BulkImportView()
                    //BulkImportView(sharedModel: exportModel) // ExportProgressView???
                    //.buttonStyle(.accessoryBar)
                        //.padding(.vertical, 4)
                        //.padding(.horizontal, 8)
                }
                if config.showDeleteAll {
                    BulkDeleteView(selection: $selection)
                    //BulkDeleteView(sharedModel: exportModel, selection: $selection) // ExportProgressView???
                    //.buttonStyle(.accessoryBar)
                        //.padding(.vertical, 4)
                        //.padding(.horizontal, 8)
                }
            }
        }
        .buttonStyle(.accessoryBar)
        .labelStyle(.iconOnly)
    }
}

#Preview {
    @Previewable @State var sortOption: SortOption = .titleAZ
    @Previewable @State var config: StorageConfiguration = StorageConfiguration()
    @Previewable @State var selection: Note? = nil
    ActionBar(sortOption: $sortOption, config: config, count: 0, selection: $selection)
}
