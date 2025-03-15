//
//  ProgressModel.swift
//  RecordText
//
//  Created by Michael Swarm on 3/7/25.
//

/*
 Common elements of ExportModel, DeleteModel, ImportModel and ContentSearchModel shared with ProgressView.
 - ProgressModel
 - ProgressBar(progress: ProgressModel)
 */

import Foundation
import SwiftUI

struct ProgressModel {
    // ProgressView
    var message: String = ""
    // var percentComplete: Double = 0.0 // Reset to 0 by resetting completed and total to 0. (Or init entire struct?)
    
    // Message Calculation
    var total: Int = 0
    var completed: Int = 0

    // Progress Calculation
    var startTime: Date = Date()
    // var estimatedTimeRemaining: TimeInterval = 0
    
    // Calculated Values
    var formattedCompletedOfTotal: String { "\(completed)/\(total)" }
    var percentComplete: Double { Double(completed) / Double(total) } // ProgressView.value parameter name
    
    // Calculation of time remaining
    private var elapsedTime: TimeInterval { Date().timeIntervalSince(startTime) }
    private var estimatedTotalTime: TimeInterval { (Double(total) / Double(completed)) * elapsedTime }
    private var remainingTime: TimeInterval { estimatedTotalTime - elapsedTime }
    var formattedRemainingTime: String { formatTimeInterval(remainingTime) }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? "Unknown"
    }
}

struct ProgressBar: View {
    @Binding var progress: ProgressModel
    
    var body: some View {
        ProgressView(progress.message, value: progress.percentComplete)
    }
}
