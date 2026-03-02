// CareCoordinator/Models/CareGroup.swift
import Foundation

struct CareGroup: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var privacyMode: PrivacyMode
    var defaultShiftStart: String  // TIME as string "HH:mm"
    var defaultShiftEnd: String
    let ownerId: UUID
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name
        case privacyMode = "privacy_mode"
        case defaultShiftStart = "default_shift_start"
        case defaultShiftEnd = "default_shift_end"
        case ownerId = "owner_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
