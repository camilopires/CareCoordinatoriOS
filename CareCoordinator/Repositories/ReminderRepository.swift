// CareCoordinator/Repositories/ReminderRepository.swift
import Foundation
import Supabase

final class ReminderRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Create Reminder

    func createReminder(
        careGroupId: UUID,
        title: String,
        time: String,
        isRecurring: Bool,
        recurrenceRule: String?,
        createdBy: UUID
    ) async throws -> Reminder {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let title: String
            let time: String
            let is_recurring: Bool
            let recurrence_rule: String?
            let created_by: UUID
        }

        return try await client
            .from("reminders")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                title: title,
                time: time,
                is_recurring: isRecurring,
                recurrence_rule: recurrenceRule,
                created_by: createdBy
            ))
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Fetch Reminders

    func fetchReminders(careGroupId: UUID) async throws -> [Reminder] {
        try await client
            .from("reminders")
            .select()
            .eq("care_group_id", value: careGroupId)
            .order("time", ascending: true)
            .execute()
            .value
    }

    // MARK: - Delete Reminder

    func deleteReminder(reminderId: UUID) async throws {
        try await client
            .from("reminders")
            .delete()
            .eq("id", value: reminderId)
            .execute()
    }
}
