// CareCoordinator/ViewModels/ScheduleViewModel.swift
import Foundation
import Observation

@Observable
final class ScheduleViewModel {
    var shifts: [Shift] = []
    var rotationPattern: RotationPattern?
    var selectedDate = Date()
    var viewMode: ViewMode = .list
    var isLoading = false
    var errorMessage: String?

    private let shiftRepo: ShiftRepository
    private let rotationRepo: RotationRepository

    init(shiftRepo: ShiftRepository = ShiftRepository(),
         rotationRepo: RotationRepository = RotationRepository()) {
        self.shiftRepo = shiftRepo
        self.rotationRepo = rotationRepo
    }

    // MARK: - View Mode

    enum ViewMode: String, CaseIterable {
        case list = "List"
        case calendar = "Calendar"
    }

    // MARK: - Computed Properties

    /// The shift for today, if one exists.
    var todayShift: Shift? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        return shifts.first { $0.date == todayStr }
    }

    /// The next upcoming shift after today.
    var nextShift: Shift? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        return shifts.first { $0.date > todayStr }
    }

    // MARK: - Actions

    func loadSchedule(careGroupId: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            rotationPattern = try await rotationRepo.fetch(careGroupId: careGroupId)
            shifts = try await shiftRepo.fetchShifts(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func saveRotationAndGenerate(
        careGroupId: UUID,
        pattern: [UUID],
        shiftStart: String,
        shiftEnd: String
    ) async {
        isLoading = true
        errorMessage = nil
        do {
            rotationPattern = try await rotationRepo.save(careGroupId: careGroupId, pattern: pattern)
            shifts = try await shiftRepo.generateShifts(
                careGroupId: careGroupId,
                pattern: pattern,
                shiftStart: shiftStart,
                shiftEnd: shiftEnd,
                startDate: Date()
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updateShift(id: UUID, carerId: UUID?, status: ShiftStatus?) async {
        do {
            let updated = try await shiftRepo.updateShift(id: id, carerId: carerId, status: status)
            if let index = shifts.firstIndex(where: { $0.id == updated.id }) {
                shifts[index] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
