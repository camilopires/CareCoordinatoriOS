// CareCoordinator/Models/PTORequest.swift
import Foundation

struct PTORequest: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    let carerId: UUID
    var startDate: String
    var endDate: String
    var reason: String?
    var status: PTOStatus
    var clientMessage: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, reason, status
        case careGroupId = "care_group_id"
        case carerId = "carer_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case clientMessage = "client_message"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
