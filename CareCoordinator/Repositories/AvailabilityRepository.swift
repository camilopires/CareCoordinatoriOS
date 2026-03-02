// CareCoordinator/Repositories/AvailabilityRepository.swift
import Foundation
import Supabase

final class AvailabilityRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func submitAvailability(
        carerId: UUID,
        careGroupId: UUID,
        date: Date,
        startTime: Date,
        endTime: Date
    ) async throws -> CarerAvailability {
        struct InsertPayload: Encodable {
            let carer_id: UUID
            let care_group_id: UUID
            let date: String
            let start_time: String
            let end_time: String
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"

        return try await client
            .from("carer_availability")
            .insert(InsertPayload(
                carer_id: carerId,
                care_group_id: careGroupId,
                date: dateFormatter.string(from: date),
                start_time: timeFormatter.string(from: startTime),
                end_time: timeFormatter.string(from: endTime)
            ))
            .select()
            .single()
            .execute()
            .value
    }

    func fetchMyAvailability(carerId: UUID) async throws -> [CarerAvailability] {
        try await client
            .from("carer_availability")
            .select()
            .eq("carer_id", value: carerId)
            .order("date", ascending: true)
            .execute()
            .value
    }

    func deleteAvailability(id: UUID) async throws {
        try await client
            .from("carer_availability")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
