// CareCoordinator/Models/RotationPattern.swift
import Foundation

struct RotationPattern: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var pattern: [UUID]  // ordered carer IDs per week
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, pattern
        case careGroupId = "care_group_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
