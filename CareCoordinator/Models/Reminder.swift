// CareCoordinator/Models/Reminder.swift
import Foundation

struct Reminder: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var title: String
    var time: String
    var isRecurring: Bool
    var recurrenceRule: String?
    let createdBy: UUID
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, time
        case careGroupId = "care_group_id"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
