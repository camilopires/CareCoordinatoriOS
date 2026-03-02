// CareCoordinator/Models/Invitation.swift
import Foundation

struct Invitation: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var code: String
    let createdBy: UUID
    var maxUses: Int
    var timesUsed: Int
    var status: InvitationStatus
    var expiresAt: Date
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, code, status
        case careGroupId = "care_group_id"
        case createdBy = "created_by"
        case maxUses = "max_uses"
        case timesUsed = "times_used"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}
