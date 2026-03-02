// CareCoordinator/Models/CareTask.swift
import Foundation

struct CareTask: Codable, Identifiable, Equatable {
    let id: UUID
    let careGroupId: UUID
    var type: TaskType
    var parentTemplateId: UUID?
    var title: String
    var description: String?
    var priority: TaskPriority
    var dueDate: String?
    var isRecurring: Bool
    var recurrenceRule: String?
    var completed: Bool
    var completedBy: UUID?
    var completedAt: Date?
    var sortOrder: Int
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, type, title, description, priority, completed
        case careGroupId = "care_group_id"
        case parentTemplateId = "parent_template_id"
        case dueDate = "due_date"
        case isRecurring = "is_recurring"
        case recurrenceRule = "recurrence_rule"
        case completedBy = "completed_by"
        case completedAt = "completed_at"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
