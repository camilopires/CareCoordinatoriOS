// CareCoordinator/Models/CarePlan.swift
import Foundation

struct CarePlan: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var title: String
    var category: String?
    var storagePath: String
    var fileSize: Int64
    let uploadedBy: UUID
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, category
        case careGroupId = "care_group_id"
        case storagePath = "storage_path"
        case fileSize = "file_size"
        case uploadedBy = "uploaded_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
