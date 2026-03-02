// CareCoordinator/Views/Dashboard/ActivityLogView.swift
import SwiftUI

struct ActivityLogView: View {
    @State private var logs: [AuditLogEntry] = []
    @State private var isLoading = false

    let careGroupId: UUID

    private let repository = AuditLogRepository()

    var body: some View {
        List {
            if isLoading && logs.isEmpty {
                ProgressView("Loading activity...")
            }

            if logs.isEmpty && !isLoading {
                ContentUnavailableView("No Activity", systemImage: "clock",
                    description: Text("Activity will appear here as events happen."))
            }

            ForEach(logs) { log in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: iconForAction(log.action))
                        .foregroundStyle(colorForAction(log.action))
                        .frame(width: 24)
                        .padding(.top, 2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(descriptionForLog(log))
                            .font(.subheadline)

                        Text(log.createdAt.formatted(.relative(presentation: .named)))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .navigationTitle("Activity")
        .refreshable {
            await loadLogs()
        }
        .task {
            await loadLogs()
        }
    }

    // MARK: - Data Loading

    private func loadLogs() async {
        isLoading = true
        logs = (try? await repository.fetchLogs(careGroupId: careGroupId)) ?? []
        isLoading = false
    }

    // MARK: - Action Mapping

    private func iconForAction(_ action: String) -> String {
        switch action {
        case "shift_created", "shift_updated": return "calendar"
        case "pto_requested": return "calendar.badge.clock"
        case "pto_approved": return "checkmark.circle"
        case "pto_denied": return "xmark.circle"
        case "task_completed": return "checkmark.square"
        case "carer_joined": return "person.badge.plus"
        case "carer_removed": return "person.badge.minus"
        case "care_plan_uploaded": return "doc.badge.plus"
        default: return "circle"
        }
    }

    private func colorForAction(_ action: String) -> Color {
        switch action {
        case "pto_approved", "task_completed", "carer_joined": return .green
        case "pto_denied", "carer_removed": return .red
        case "pto_requested": return .orange
        default: return .blue
        }
    }

    private func descriptionForLog(_ log: AuditLogEntry) -> String {
        switch log.action {
        case "shift_created": return "New shift created"
        case "shift_updated": return "Shift updated"
        case "pto_requested": return "PTO request submitted"
        case "pto_approved": return "PTO request approved"
        case "pto_denied": return "PTO request denied"
        case "task_completed": return "Task completed"
        case "carer_joined": return "New carer joined"
        case "carer_removed": return "Carer removed"
        case "care_plan_uploaded": return "Care plan uploaded"
        default: return log.action.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
