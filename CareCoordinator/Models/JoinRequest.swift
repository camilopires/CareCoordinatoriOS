// CareCoordinator/Models/JoinRequest.swift
import Foundation

struct JoinRequest: Codable, Identifiable, Equatable {
    let id: UUID
    let invitationId: UUID
    let carerId: UUID
    var status: JoinRequestStatus
    var reviewedAt: Date?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, status
        case invitationId = "invitation_id"
        case carerId = "carer_id"
        case reviewedAt = "reviewed_at"
        case createdAt = "created_at"
    }
}
