// CareCoordinator/Repositories/TaskRepository.swift
import Foundation
import Supabase

final class TaskRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Swapover Template

    func fetchSwapoverTemplate(careGroupId: UUID) async throws -> [CareTask] {
        try await client
            .from("tasks")
            .select()
            .eq("care_group_id", value: careGroupId)
            .eq("type", value: TaskType.swapoverTemplate.rawValue)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    func createSwapoverTemplateItem(
        careGroupId: UUID,
        title: String,
        description: String?,
        sortOrder: Int
    ) async throws -> CareTask {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let description: String?
            let type: String
            let sort_order: Int
        }

        return try await client
            .from("tasks")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                title: title,
                description: description,
                type: TaskType.swapoverTemplate.rawValue,
                sort_order: sortOrder
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func deleteTemplateItem(taskId: UUID) async throws {
        try await client
            .from("tasks")
            .delete()
            .eq("id", value: taskId)
            .execute()
    }

    // MARK: - Swapover Instances

    /// Auto-generate swapover instance from template for a specific shift swap date
    func generateSwapoverInstance(
        careGroupId: UUID,
        templateItems: [CareTask],
        assignedTo: UUID?,
        dueDate: Date
    ) async throws -> [CareTask] {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let description: String?
            let type: String
            let assigned_to: UUID?
            let due_date: String
            let sort_order: Int
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let payloads = templateItems.map { item in
            InsertPayload(
                care_group_id: careGroupId,
                title: item.title,
                description: item.description,
                type: TaskType.swapoverInstance.rawValue,
                assigned_to: assignedTo,
                due_date: formatter.string(from: dueDate),
                sort_order: item.sortOrder
            )
        }

        return try await client
            .from("tasks")
            .insert(payloads)
            .select()
            .execute()
            .value
    }

    // MARK: - General Tasks

    func fetchGeneralTasks(careGroupId: UUID) async throws -> [CareTask] {
        try await client
            .from("tasks")
            .select()
            .eq("care_group_id", value: careGroupId)
            .eq("type", value: TaskType.general.rawValue)
            .order("due_date", ascending: true)
            .execute()
            .value
    }

    func createGeneralTask(
        careGroupId: UUID,
        title: String,
        description: String?,
        assignedTo: UUID?,
        dueDate: Date?,
        priority: TaskPriority,
        isRecurring: Bool,
        recurrenceRule: String?
    ) async throws -> CareTask {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let description: String?
            let type: String
            let assigned_to: UUID?
            let due_date: String?
            let priority: String
            let is_recurring: Bool
            let recurrence_rule: String?
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return try await client
            .from("tasks")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                title: title,
                description: description,
                type: TaskType.general.rawValue,
                assigned_to: assignedTo,
                due_date: dueDate.map { formatter.string(from: $0) },
                priority: priority.rawValue,
                is_recurring: isRecurring,
                recurrence_rule: recurrenceRule
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func toggleTaskCompletion(taskId: UUID, completed: Bool, completedBy: UUID?) async throws {
        struct UpdatePayload: Encodable {
            let completed: Bool
            let completed_by: UUID?
            let completed_at: String?
        }

        let formatter = ISO8601DateFormatter()

        try await client
            .from("tasks")
            .update(UpdatePayload(
                completed: completed,
                completed_by: completed ? completedBy : nil,
                completed_at: completed ? formatter.string(from: Date()) : nil
            ))
            .eq("id", value: taskId)
            .execute()
    }

    func deleteTask(taskId: UUID) async throws {
        try await client
            .from("tasks")
            .delete()
            .eq("id", value: taskId)
            .execute()
    }
}
