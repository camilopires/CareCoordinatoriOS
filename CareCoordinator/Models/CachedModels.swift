// CareCoordinator/Models/CachedModels.swift
import Foundation
import SwiftData

@Model
final class CachedShift {
    @Attribute(.unique) var id: UUID
    var careGroupId: UUID
    var carerId: UUID?
    var date: String
    var startTime: String
    var endTime: String
    var status: String
    var isManuallyEdited: Bool
    var lastSynced: Date

    init(from shift: Shift) {
        self.id = shift.id
        self.careGroupId = shift.careGroupId
        self.carerId = shift.carerId
        self.date = shift.date
        self.startTime = shift.startTime
        self.endTime = shift.endTime
        self.status = shift.status.rawValue
        self.isManuallyEdited = shift.isManuallyEdited
        self.lastSynced = Date()
    }

    func toShift() -> Shift {
        Shift(
            id: id,
            careGroupId: careGroupId,
            carerId: carerId,
            date: date,
            startTime: startTime,
            endTime: endTime,
            status: ShiftStatus(rawValue: status) ?? .scheduled,
            isManuallyEdited: isManuallyEdited,
            originalCarerId: nil,
            createdAt: lastSynced,
            updatedAt: lastSynced
        )
    }
}

@Model
final class CachedTask {
    @Attribute(.unique) var id: UUID
    var careGroupId: UUID
    var type: String
    var title: String
    var taskDescription: String?
    var priority: String
    var dueDate: String?
    var isRecurring: Bool
    var recurrenceRule: String?
    var completed: Bool
    var completedBy: UUID?
    var sortOrder: Int
    var lastSynced: Date

    init(from task: CareTask) {
        self.id = task.id
        self.careGroupId = task.careGroupId
        self.type = task.type.rawValue
        self.title = task.title
        self.taskDescription = task.description
        self.priority = task.priority.rawValue
        self.dueDate = task.dueDate
        self.isRecurring = task.isRecurring
        self.recurrenceRule = task.recurrenceRule
        self.completed = task.completed
        self.completedBy = task.completedBy
        self.sortOrder = task.sortOrder
        self.lastSynced = Date()
    }
}

@Model
final class PendingSyncAction {
    @Attribute(.unique) var id: UUID
    var entityType: String  // "task", "shift", etc.
    var entityId: UUID
    var action: String      // "update", "create", "delete"
    var payload: Data       // JSON-encoded changes
    var createdAt: Date

    init(entityType: String, entityId: UUID, action: String, payload: Data) {
        self.id = UUID()
        self.entityType = entityType
        self.entityId = entityId
        self.action = action
        self.payload = payload
        self.createdAt = Date()
    }
}
