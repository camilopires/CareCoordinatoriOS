// CareCoordinator/Repositories/EmergencyContactRepository.swift
import Foundation
import Supabase

final class EmergencyContactRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Create Contact

    func createContact(
        careGroupId: UUID,
        name: String,
        phone: String,
        relationship: String,
        sortOrder: Int
    ) async throws -> EmergencyContact {
        struct InsertPayload: Encodable {
            let care_group_id: UUID
            let name: String
            let phone: String
            let relationship: String
            let sort_order: Int
        }

        return try await client
            .from("emergency_contacts")
            .insert(InsertPayload(
                care_group_id: careGroupId,
                name: name,
                phone: phone,
                relationship: relationship,
                sort_order: sortOrder
            ))
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Fetch Contacts

    func fetchContacts(careGroupId: UUID) async throws -> [EmergencyContact] {
        try await client
            .from("emergency_contacts")
            .select()
            .eq("care_group_id", value: careGroupId)
            .order("sort_order", ascending: true)
            .execute()
            .value
    }

    // MARK: - Delete Contact

    func deleteContact(contactId: UUID) async throws {
        try await client
            .from("emergency_contacts")
            .delete()
            .eq("id", value: contactId)
            .execute()
    }
}
