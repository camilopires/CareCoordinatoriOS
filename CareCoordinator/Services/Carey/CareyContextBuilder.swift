// CareCoordinator/Services/Carey/CareyContextBuilder.swift
import Foundation

struct CareyContext {
    let systemPrompt: String
    let contextData: String
}

final class CareyContextBuilder {
    func buildContext(
        profile: Profile,
        careGroup: CareGroup,
        shifts: [Shift],
        tasks: [CareTask],
        carerNames: [UUID: String]?,
        carePlanTexts: [String]?
    ) -> CareyContext {
        let isClient = profile.role == .client
        let privacyMode = careGroup.privacyMode

        var systemPrompt = """
        You are Care-y, a helpful assistant for a home care coordination app called CareCoordinator.
        You help \(isClient ? "clients manage their care group" : "carers manage their shifts and tasks").

        Important rules:
        - Only answer questions about care coordination, scheduling, tasks, and care plans.
        - Be warm, helpful, and concise.
        - If you don't have enough information to answer, say so clearly.
        """

        if !isClient {
            switch privacyMode {
            case .full:
                systemPrompt += "\n- PRIVACY: You must NOT reveal information about other carers, their schedules, or their names."
            case .anonymous:
                systemPrompt += "\n- PRIVACY: You may reference other carers' schedules but must NOT reveal their names."
            case .open:
                break // No restrictions
            }
        }

        var contextParts: [String] = []

        // Schedule context
        let relevantShifts = filterShifts(shifts, for: profile, privacyMode: privacyMode)
        if !relevantShifts.isEmpty {
            contextParts.append("## Current Schedule")
            for shift in relevantShifts.prefix(20) {
                let carerLabel: String
                if isClient || privacyMode == .open {
                    carerLabel = shift.carerId.flatMap { carerNames?[$0] } ?? "Unassigned"
                } else if privacyMode == .anonymous {
                    carerLabel = "A carer"
                } else {
                    carerLabel = shift.carerId == profile.id ? "You" : "Another carer"
                }
                contextParts.append("- \(shift.date): \(carerLabel) (\(shift.startTime) - \(shift.endTime)) [Status: \(shift.status.rawValue)]")
            }
        }

        // Tasks context
        let activeTasks = tasks.filter { !$0.completed }
        if !activeTasks.isEmpty {
            contextParts.append("\n## Active Tasks")
            for task in activeTasks.prefix(15) {
                let dueStr = task.dueDate.map { " (due: \($0))" } ?? ""
                contextParts.append("- \(task.title)\(dueStr)")
            }
        }

        // Care plan text context (if available)
        if let planTexts = carePlanTexts, !planTexts.isEmpty {
            contextParts.append("\n## Care Plan Information")
            for text in planTexts.prefix(3) {
                contextParts.append(String(text.prefix(2000))) // Limit per plan
            }
        }

        contextParts.append("\n## Today's Date: \(Date().formatted(date: .complete, time: .omitted))")

        return CareyContext(
            systemPrompt: systemPrompt,
            contextData: contextParts.joined(separator: "\n")
        )
    }

    private func filterShifts(_ shifts: [Shift], for profile: Profile, privacyMode: PrivacyMode) -> [Shift] {
        if profile.role == .client || privacyMode == .open || privacyMode == .anonymous {
            return shifts
        }
        // Full privacy: only show own shifts
        return shifts.filter { $0.carerId == profile.id }
    }
}
