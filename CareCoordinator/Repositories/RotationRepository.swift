// CareCoordinator/Repositories/RotationRepository.swift
import Foundation
import Supabase

final class RotationRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func save(careGroupId: UUID, pattern: [UUID]) async throws -> RotationPattern {
        struct Upsert: Encodable {
            let care_group_id: String
            let pattern: [String]
        }

        // Delete existing pattern first (one pattern per group)
        try await client
            .from("rotation_patterns")
            .delete()
            .eq("care_group_id", value: careGroupId.uuidString)
            .execute()

        let result: RotationPattern = try await client
            .from("rotation_patterns")
            .insert(Upsert(
                care_group_id: careGroupId.uuidString,
                pattern: pattern.map(\.uuidString)
            ))
            .select()
            .single()
            .execute()
            .value

        return result
    }

    func fetch(careGroupId: UUID) async throws -> RotationPattern? {
        let patterns: [RotationPattern] = try await client
            .from("rotation_patterns")
            .select()
            .eq("care_group_id", value: careGroupId.uuidString)
            .execute()
            .value

        return patterns.first
    }
}
