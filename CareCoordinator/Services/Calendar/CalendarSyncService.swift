// CareCoordinator/Services/Calendar/CalendarSyncService.swift
import EventKit
import Foundation
import UIKit

final class CalendarSyncService {
    private let eventStore = EKEventStore()
    private let calendarTitle = "CareCoordinator"

    // MARK: - Permission

    func requestAccess() async -> Bool {
        do {
            return try await eventStore.requestFullAccessToEvents()
        } catch {
            return false
        }
    }

    var hasAccess: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    // MARK: - Calendar Management

    /// Get or create the dedicated CareCoordinator calendar.
    func getOrCreateCalendar() throws -> EKCalendar {
        // Check if it already exists
        if let existing = eventStore.calendars(for: .event).first(where: { $0.title == calendarTitle }) {
            return existing
        }

        // Create new calendar
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = calendarTitle
        calendar.cgColor = UIColor.systemBlue.cgColor

        // Use the default calendar source (iCloud or local)
        if let source = eventStore.defaultCalendarForNewEvents?.source {
            calendar.source = source
        } else if let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) {
            calendar.source = localSource
        } else {
            throw CalendarSyncError.noCalendarSource
        }

        try eventStore.saveCalendar(calendar, commit: true)
        return calendar
    }

    // MARK: - Sync Shifts

    /// Syncs an array of shifts into the CareCoordinator calendar.
    /// Creates new events, updates existing ones (matched by shift ID stored in notes),
    /// and removes orphaned events for shifts no longer in the list.
    func syncShifts(_ shifts: [Shift], carerNames: [UUID: String]?) async throws {
        guard hasAccess else { throw CalendarSyncError.noPermission }

        let calendar = try getOrCreateCalendar()

        guard !shifts.isEmpty else { return }

        // Build date range from shifts (dates are "yyyy-MM-dd" strings)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let shiftDates = shifts.compactMap { dateFormatter.date(from: $0.date) }
        guard let minDate = shiftDates.min(),
              let maxDate = shiftDates.max() else { return }

        let predicate = eventStore.predicateForEvents(
            withStart: minDate,
            end: Calendar.current.date(byAdding: .day, value: 1, to: maxDate)!,
            calendars: [calendar]
        )
        let existingEvents = eventStore.events(matching: predicate)

        // Build a lookup by shift ID stored in event notes
        var existingByShiftId: [UUID: EKEvent] = [:]
        for event in existingEvents {
            if let notes = event.notes,
               let shiftId = UUID(uuidString: notes) {
                existingByShiftId[shiftId] = event
            }
        }

        // Sync each shift
        for shift in shifts {
            let event: EKEvent
            if let existing = existingByShiftId[shift.id] {
                event = existing
                existingByShiftId.removeValue(forKey: shift.id)
            } else {
                event = EKEvent(eventStore: eventStore)
                event.calendar = calendar
            }

            // Build title based on shift info
            let carerName = shift.carerId.flatMap { carerNames?[$0] } ?? "Unassigned"
            event.title = "Shift: \(carerName)"

            // Combine date + time strings into full dates
            event.startDate = combineDateAndTime(dateString: shift.date, timeString: shift.startTime)
            event.endDate = combineDateAndTime(dateString: shift.date, timeString: shift.endTime)

            // Store shift ID for future sync matching
            event.notes = shift.id.uuidString

            if shift.status == .cancelled {
                event.title = "[Cancelled] \(event.title ?? "")"
            }

            try eventStore.save(event, span: .thisEvent)
        }

        // Remove events for shifts no longer in the list
        for (_, orphanEvent) in existingByShiftId {
            try eventStore.remove(orphanEvent, span: .thisEvent)
        }

        try eventStore.commit()
    }

    // MARK: - Remove All Events

    func removeAllEvents() throws {
        guard let calendar = eventStore.calendars(for: .event).first(where: { $0.title == calendarTitle }) else {
            return
        }

        let predicate = eventStore.predicateForEvents(
            withStart: Date.distantPast,
            end: Date.distantFuture,
            calendars: [calendar]
        )
        let events = eventStore.events(matching: predicate)
        for event in events {
            try eventStore.remove(event, span: .thisEvent)
        }
        try eventStore.commit()
    }

    // MARK: - Helpers

    private func combineDateAndTime(dateString: String, timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.date(from: "\(dateString) \(timeString)") ?? Date()
    }
}

// MARK: - Errors

enum CalendarSyncError: LocalizedError {
    case noPermission
    case noCalendarSource

    var errorDescription: String? {
        switch self {
        case .noPermission: return "Calendar access not granted. Enable in Settings."
        case .noCalendarSource: return "No calendar source available on this device."
        }
    }
}
