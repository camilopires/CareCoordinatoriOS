// CareCoordinator/Models/AuditLogEntry.swift
import Foundation

struct AuditLogEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    let userId: UUID
    var action: String
    var details: [String: String]?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, action, details
        case careGroupId = "care_group_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
