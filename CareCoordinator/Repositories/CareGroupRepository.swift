// CareCoordinator/Repositories/CareGroupRepository.swift
import Foundation
import Supabase

final class CareGroupRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func create(name: String, privacyMode: PrivacyMode, shiftStart: String, shiftEnd: String) async throws -> CareGroup {
        let userId = try await client.auth.session.user.id

        struct Insert: Encodable {
            let name: String
            let privacy_mode: String
            let default_shift_start: String
            let default_shift_end: String
            let owner_id: String
        }

        let careGroup: CareGroup = try await client
            .from("care_groups")
            .insert(Insert(
                name: name,
                privacy_mode: privacyMode.rawValue,
                default_shift_start: shiftStart,
                default_shift_end: shiftEnd,
                owner_id: userId.uuidString
            ))
            .select()
            .single()
            .execute()
            .value

        // Update profile with care_group_id
        try await client
            .from("profiles")
            .update(["care_group_id": careGroup.id.uuidString])
            .eq("id", value: userId.uuidString)
            .execute()

        return careGroup
    }

    func fetchForCurrentUser() async throws -> CareGroup? {
        let userId = try await client.auth.session.user.id

        let groups: [CareGroup] = try await client
            .from("care_groups")
            .select()
            .eq("owner_id", value: userId.uuidString)
            .execute()
            .value

        return groups.first
    }
}
