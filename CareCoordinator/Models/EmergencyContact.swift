// CareCoordinator/Models/EmergencyContact.swift
import Foundation

struct EmergencyContact: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var name: String
    var phone: String
    var relationship: String
    var sortOrder: Int
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, phone, relationship
        case careGroupId = "care_group_id"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
