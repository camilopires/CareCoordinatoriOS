// CareCoordinator/Repositories/AuditLogRepository.swift
import Foundation
import Supabase

final class AuditLogRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Fetch Logs

    func fetchLogs(careGroupId: UUID, limit: Int = 50) async throws -> [AuditLogEntry] {
        try await client
            .from("audit_log")
            .select()
            .eq("care_group_id", value: careGroupId)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    // MARK: - Log Action

    func logAction(
        careGroupId: UUID,
        userId: UUID,
        action: String,
        details: [String: String]? = nil
    ) async throws {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let user_id: UUID
            let action: String
            let details: [String: String]?
        }

        try await client
            .from("audit_log")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                user_id: userId,
                action: action,
                details: details
            ))
            .execute()
    }
}
