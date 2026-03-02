// CareCoordinator/Views/Notifications/NotificationRowView.swift
import SwiftUI

struct NotificationRowView: View {
    let notification: CareNotification

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .font(.title3)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(notification.read ? .regular : .semibold)

                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(notification.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if !notification.read {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 2)
    }

    private var iconName: String {
        switch notification.type {
        case .joinRequest: return "person.badge.plus"
        case .ptoRequest: return "calendar.badge.clock"
        case .shiftChange: return "arrow.triangle.2.circlepath"
        case .taskAssigned: return "checklist"
        case .openShift: return "person.fill.questionmark"
        case .ptoDecision: return "calendar.badge.checkmark"
        case .reminder: return "bell.fill"
        case .carePlanUpdate: return "heart.text.clipboard"
        }
    }

    private var iconColor: Color {
        switch notification.type {
        case .joinRequest: return .blue
        case .ptoRequest: return .orange
        case .shiftChange: return .purple
        case .taskAssigned: return .green
        case .openShift: return .teal
        case .ptoDecision: return .orange
        case .reminder: return .red
        case .carePlanUpdate: return .pink
        }
    }
}
