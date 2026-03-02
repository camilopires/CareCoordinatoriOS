// CareCoordinator/Views/Schedule/ShiftRowView.swift
import SwiftUI

struct ShiftRowView: View {
    let shift: Shift

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(shift.date)
                    .font(.headline)
                Text("\(shift.startTime) - \(shift.endTime)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(shift.status.rawValue.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .clipShape(Capsule())
        }
    }

    private var statusColor: Color {
        switch shift.status {
        case .scheduled: .blue
        case .needingCover: .orange
        case .covered: .green
        case .completed: .gray
        case .cancelled: .red
        }
    }
}
