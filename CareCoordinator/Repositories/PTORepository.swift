// CareCoordinator/Repositories/PTORepository.swift
import Foundation
import Supabase

final class PTORepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Create

    /// Submits a new PTO request for a carer.
    func createPTORequest(
        carerId: UUID,
        careGroupId: UUID,
        startDate: String,
        endDate: String,
        reason: String?
    ) async throws -> PTORequest {
        struct InsertPayload: Encodable {
            let carer_id: String
            let care_group_id: String
            let start_date: String
            let end_date: String
            let reason: String?
        }

        return try await client
            .from("pto_requests")
            .insert(InsertPayload(
                carer_id: carerId.uuidString,
                care_group_id: careGroupId.uuidString,
                start_date: startDate,
                end_date: endDate,
                reason: reason
            ))
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Fetch

    /// Fetches all PTO requests for a care group, ordered by start date ascending.
    func fetchPTORequests(careGroupId: UUID) async throws -> [PTORequest] {
        try await client
            .from("pto_requests")
            .select()
            .eq("care_group_id", value: careGroupId.uuidString)
            .order("start_date", ascending: true)
            .execute()
            .value
    }

    /// Fetches PTO requests submitted by a specific carer.
    func fetchMyPTORequests(carerId: UUID) async throws -> [PTORequest] {
        try await client
            .from("pto_requests")
            .select()
            .eq("carer_id", value: carerId.uuidString)
            .order("start_date", ascending: true)
            .execute()
            .value
    }

    // MARK: - Approve / Deny

    /// Client approves a PTO request.
    func approvePTO(requestId: UUID) async throws {
        try await client
            .from("pto_requests")
            .update(["status": "approved"])
            .eq("id", value: requestId.uuidString)
            .execute()
    }

    /// Client denies a PTO request with an optional message.
    func denyPTO(requestId: UUID, message: String? = nil) async throws {
        var updates: [String: String] = ["status": "denied"]
        if let message {
            updates["client_message"] = message
        }

        try await client
            .from("pto_requests")
            .update(updates)
            .eq("id", value: requestId.uuidString)
            .execute()
    }
}
