// CareCoordinator/Models/Profile.swift
import Foundation

struct Profile: Codable, Identifiable, Equatable {
    let id: UUID
    var role: UserRole
    var careGroupId: UUID?
    var displayName: String
    var email: String
    var publicKey: Data?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, role, email
        case careGroupId = "care_group_id"
        case displayName = "display_name"
        case publicKey = "public_key"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
