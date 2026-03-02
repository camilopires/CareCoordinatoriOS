// CareCoordinator/Repositories/InvitationRepository.swift
import Foundation
import Supabase

final class InvitationRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func createInvitation(careGroupId: UUID, expiresInDays: Int = 7) async throws -> Invitation {
        let userId = try await client.auth.session.user.id
        let code = generateInviteCode()
        let expiresAt = Calendar.current.date(byAdding: .day, value: expiresInDays, to: Date())!

        struct Insert: Encodable {
            let care_group_id: String
            let code: String
            let created_by: String
            let expires_at: String
        }

        let formatter = ISO8601DateFormatter()

        let invitation: Invitation = try await client
            .from("invitations")
            .insert(Insert(
                care_group_id: careGroupId.uuidString,
                code: code,
                created_by: userId.uuidString,
                expires_at: formatter.string(from: expiresAt)
            ))
            .select()
            .single()
            .execute()
            .value

        return invitation
    }

    func lookupInvitation(code: String) async throws -> Invitation? {
        let invitations: [Invitation] = try await client
            .from("invitations")
            .select()
            .eq("code", value: code)
            .eq("status", value: "active")
            .execute()
            .value

        return invitations.first
    }

    func createJoinRequest(invitationId: UUID) async throws -> JoinRequest {
        let userId = try await client.auth.session.user.id

        struct Insert: Encodable {
            let invitation_id: String
            let carer_id: String
        }

        let request: JoinRequest = try await client
            .from("join_requests")
            .insert(Insert(
                invitation_id: invitationId.uuidString,
                carer_id: userId.uuidString
            ))
            .select()
            .single()
            .execute()
            .value

        return request
    }

    func fetchPendingJoinRequests(careGroupId: UUID) async throws -> [JoinRequest] {
        let requests: [JoinRequest] = try await client
            .from("join_requests")
            .select("*, invitations!inner(care_group_id)")
            .eq("status", value: "pending")
            .execute()
            .value

        return requests
    }

    func approveJoinRequest(requestId: UUID, carerId: UUID, careGroupId: UUID) async throws {
        // Update join request status
        try await client
            .from("join_requests")
            .update(["status": "approved", "reviewed_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: requestId.uuidString)
            .execute()

        // Update carer's profile with care_group_id
        try await client
            .from("profiles")
            .update(["care_group_id": careGroupId.uuidString])
            .eq("id", value: carerId.uuidString)
            .execute()
    }

    func denyJoinRequest(requestId: UUID) async throws {
        try await client
            .from("join_requests")
            .update(["status": "denied", "reviewed_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: requestId.uuidString)
            .execute()
    }

    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" // No I/O/0/1 for clarity
        return String((0..<8).map { _ in chars.randomElement()! })
    }
}
