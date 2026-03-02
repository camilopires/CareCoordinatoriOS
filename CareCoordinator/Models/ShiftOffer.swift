// CareCoordinator/Models/ShiftOffer.swift
import Foundation

struct ShiftOffer: Codable, Identifiable, Equatable {
    let id: UUID
    let shiftId: UUID
    var offeredTo: UUID?
    var status: ShiftOfferStatus
    var acceptedBy: UUID?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, status
        case shiftId = "shift_id"
        case offeredTo = "offered_to"
        case acceptedBy = "accepted_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
