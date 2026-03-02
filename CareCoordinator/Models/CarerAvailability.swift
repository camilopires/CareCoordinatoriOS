// CareCoordinator/Models/CarerAvailability.swift
import Foundation

struct CarerAvailability: Codable, Identifiable, Equatable {
    let id: UUID
    let carerId: UUID
    let careGroupId: UUID
    var date: String
    var startTime: String?
    var endTime: String?
    var isRecurring: Bool
    var recurrenceRule: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, date
        case carerId = "carer_id"
        case careGroupId = "care_group_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
