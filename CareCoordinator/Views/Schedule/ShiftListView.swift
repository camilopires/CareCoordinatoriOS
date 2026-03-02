// CareCoordinator/Views/Schedule/ShiftListView.swift
import SwiftUI

struct ShiftListView: View {
    let shifts: [Shift]

    var body: some View {
        List(shifts) { shift in
            NavigationLink {
                ShiftDetailView(shift: shift)
            } label: {
                ShiftRowView(shift: shift)
            }
        }
        .overlay {
            if shifts.isEmpty {
                ContentUnavailableView(
                    "No Shifts",
                    systemImage: "calendar",
                    description: Text("Set up a rotation pattern to generate shifts")
                )
            }
        }
    }
}
