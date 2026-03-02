// CareCoordinator/Models/ShiftNote.swift
import Foundation

struct ShiftNote: Codable, Identifiable, Equatable {
    let id: UUID
    let shiftId: UUID
    let carerId: UUID
    var content: String  // encrypted client-side
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case shiftId = "shift_id"
        case carerId = "carer_id"
        case content = "encrypted_content"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
