// CareCoordinator/Repositories/NotificationRepository.swift
import Foundation
import Supabase

final class NotificationRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func fetchNotifications(userId: UUID) async throws -> [CareNotification] {
        try await client
            .from("notifications")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()
            .value
    }

    func fetchUnreadCount(userId: UUID) async throws -> Int {
        let notifications: [CareNotification] = try await client
            .from("notifications")
            .select()
            .eq("user_id", value: userId)
            .eq("read", value: false)
            .execute()
            .value
        return notifications.count
    }

    func markAsRead(notificationId: UUID) async throws {
        try await client
            .from("notifications")
            .update(["read": true])
            .eq("id", value: notificationId)
            .execute()
    }

    func markAllAsRead(userId: UUID) async throws {
        try await client
            .from("notifications")
            .update(["read": true])
            .eq("user_id", value: userId)
            .eq("read", value: false)
            .execute()
    }

    func createNotification(
        userId: UUID,
        type: NotificationType,
        title: String,
        body: String,
        data: [String: String]? = nil
    ) async throws {
        struct InsertPayload: Encodable {
            let user_id: UUID
            let type: String
            let title: String
            let body: String
            let data: [String: String]?
        }

        try await client
            .from("notifications")
            .insert(InsertPayload(
                user_id: userId,
                type: type.rawValue,
                title: title,
                body: body,
                data: data
            ))
            .execute()
    }
}
