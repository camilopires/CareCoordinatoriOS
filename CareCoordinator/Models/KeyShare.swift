// CareCoordinator/Models/KeyShare.swift
import Foundation

struct KeyShare: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    let userId: UUID
    var encryptedGroupKey: Data
    var senderPublicKey: Data
    var keyVersion: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case careGroupId = "care_group_id"
        case userId = "user_id"
        case encryptedGroupKey = "encrypted_group_key"
        case senderPublicKey = "sender_public_key"
        case keyVersion = "key_version"
        case createdAt = "created_at"
    }
}
