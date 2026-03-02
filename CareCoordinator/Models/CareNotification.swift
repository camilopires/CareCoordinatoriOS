// CareCoordinator/Models/CareNotification.swift
import Foundation

struct CareNotification: Codable, Identifiable, Equatable {
    let id: UUID
    let userId: UUID
    var type: NotificationType
    var title: String
    var body: String
    var data: [String: String]?
    var read: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, type, title, body, data, read
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
