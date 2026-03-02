// CareCoordinator/Repositories/ShiftOfferRepository.swift
import Foundation
import Supabase

final class ShiftOfferRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Create

    /// Client creates a shift offer after approving PTO, broadcasting to available carers.
    func createShiftOffer(shiftId: UUID, offeredTo: UUID? = nil) async throws -> ShiftOffer {
        struct InsertPayload: Encodable {
            let shift_id: String
            let offered_to: String?
        }

        return try await client
            .from("shift_offers")
            .insert(InsertPayload(
                shift_id: shiftId.uuidString,
                offered_to: offeredTo?.uuidString
            ))
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Fetch

    /// Fetches open (pending) shift offers for a care group by joining through the shifts table.
    func fetchOpenOffers(careGroupId: UUID) async throws -> [ShiftOffer] {
        try await client
            .from("shift_offers")
            .select("*, shifts!inner(care_group_id)")
            .eq("shifts.care_group_id", value: careGroupId.uuidString)
            .eq("status", value: "pending")
            .execute()
            .value
    }

    // MARK: - Accept / Decline

    /// Carer accepts an open shift offer.
    func acceptShift(offerId: UUID, carerId: UUID) async throws {
        try await client
            .from("shift_offers")
            .update([
                "accepted_by": carerId.uuidString,
                "status": "accepted"
            ])
            .eq("id", value: offerId.uuidString)
            .execute()
    }

    /// Carer declines a shift offer.
    func declineShift(offerId: UUID) async throws {
        try await client
            .from("shift_offers")
            .update(["status": "declined"])
            .eq("id", value: offerId.uuidString)
            .execute()
    }

    // MARK: - Confirm

    /// Client confirms an accepted offer and reassigns the shift to the new carer.
    func confirmAcceptedOffer(offerId: UUID, shiftId: UUID, newCarerId: UUID) async throws {
        // Update the shift to the new carer
        try await client
            .from("shifts")
            .update([
                "carer_id": newCarerId.uuidString,
                "status": "covered"
            ])
            .eq("id", value: shiftId.uuidString)
            .execute()

        // Mark offer as expired (completed) since it's been fulfilled
        try await client
            .from("shift_offers")
            .update(["status": "expired"])
            .eq("id", value: offerId.uuidString)
            .execute()
    }
}
