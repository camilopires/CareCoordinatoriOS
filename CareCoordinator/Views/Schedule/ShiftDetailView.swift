// CareCoordinator/Views/Schedule/ShiftDetailView.swift
import SwiftUI

struct ShiftDetailView: View {
    let shift: Shift

    var body: some View {
        List {
            Section("Shift Details") {
                LabeledContent("Date", value: shift.date)
                LabeledContent("Time", value: "\(shift.startTime) - \(shift.endTime)")
                LabeledContent("Status", value: shift.status.rawValue.capitalized)
            }

            if let carerId = shift.carerId {
                Section("Carer") {
                    LabeledContent("Carer ID", value: carerId.uuidString)
                }
            }

            if shift.isManuallyEdited {
                Section {
                    Label("This shift was manually edited", systemImage: "pencil.circle")
                        .foregroundStyle(.orange)
                }
            }
        }
        .navigationTitle("Shift")
    }
}
