// CareCoordinator/Models/Shift.swift
import Foundation

struct Shift: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var carerId: UUID?
    var date: String  // DATE as "yyyy-MM-dd"
    var startTime: String  // TIME as "HH:mm"
    var endTime: String
    var status: ShiftStatus
    var isManuallyEdited: Bool
    var originalCarerId: UUID?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, date, status
        case careGroupId = "care_group_id"
        case carerId = "carer_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case isManuallyEdited = "is_manually_edited"
        case originalCarerId = "original_carer_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
