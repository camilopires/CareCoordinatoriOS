// CareCoordinator/Repositories/ShiftRepository.swift
import Foundation
import Supabase

final class ShiftRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Generate Shifts

    /// Generates shifts for a 12-week look-ahead (default) from a rotation pattern.
    /// Deletes existing auto-generated future shifts before inserting new ones.
    func generateShifts(
        careGroupId: UUID,
        pattern: [UUID],
        shiftStart: String,
        shiftEnd: String,
        startDate: Date,
        weeksAhead: Int = 12
    ) async throws -> [Shift] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDateStr = formatter.string(from: startDate)

        // Delete future auto-generated shifts (not manually edited)
        try await client
            .from("shifts")
            .delete()
            .eq("care_group_id", value: careGroupId.uuidString)
            .gte("date", value: startDateStr)
            .eq("is_manually_edited", value: false)
            .execute()

        // Generate new shifts
        var shifts: [ShiftInsert] = []
        let calendar = Calendar.current
        let patternLength = pattern.count

        guard patternLength > 0 else { return [] }

        for weekOffset in 0..<weeksAhead {
            let carerIndex = weekOffset % patternLength
            let carerId = pattern[carerIndex]

            // Generate 7 days of shifts for this week
            for dayOffset in 0..<7 {
                let totalDayOffset = (weekOffset * 7) + dayOffset
                guard let shiftDate = calendar.date(byAdding: .day, value: totalDayOffset, to: startDate) else { continue }
                let dateStr = formatter.string(from: shiftDate)

                shifts.append(ShiftInsert(
                    care_group_id: careGroupId.uuidString,
                    carer_id: carerId.uuidString,
                    date: dateStr,
                    start_time: shiftStart,
                    end_time: shiftEnd,
                    status: "scheduled"
                ))
            }
        }

        // Batch insert
        try await client
            .from("shifts")
            .insert(shifts)
            .execute()

        // Fetch back the created shifts
        let created: [Shift] = try await client
            .from("shifts")
            .select()
            .eq("care_group_id", value: careGroupId.uuidString)
            .gte("date", value: startDateStr)
            .order("date", ascending: true)
            .execute()
            .value

        return created
    }

    // MARK: - Fetch Shifts

    /// Fetches shifts for a care group, optionally filtered by date range.
    func fetchShifts(careGroupId: UUID, from startDate: String? = nil, to endDate: String? = nil) async throws -> [Shift] {
        var query = client
            .from("shifts")
            .select()
            .eq("care_group_id", value: careGroupId.uuidString)

        if let start = startDate {
            query = query.gte("date", value: start)
        }
        if let end = endDate {
            query = query.lte("date", value: end)
        }

        let shifts: [Shift] = try await query
            .order("date", ascending: true)
            .execute()
            .value

        return shifts
    }

    // MARK: - Update Shift

    /// Updates a shift's carer and/or status, marking it as manually edited.
    func updateShift(id: UUID, carerId: UUID?, status: ShiftStatus?) async throws -> Shift {
        var updates: [String: String] = [:]
        if let carerId { updates["carer_id"] = carerId.uuidString }
        if let status { updates["status"] = status.rawValue }
        updates["is_manually_edited"] = "true"

        let shift: Shift = try await client
            .from("shifts")
            .update(updates)
            .eq("id", value: id.uuidString)
            .select()
            .single()
            .execute()
            .value

        return shift
    }
}

// MARK: - Insert DTO

private struct ShiftInsert: Encodable {
    let care_group_id: String
    let carer_id: String
    let date: String
    let start_time: String
    let end_time: String
    let status: String
}
