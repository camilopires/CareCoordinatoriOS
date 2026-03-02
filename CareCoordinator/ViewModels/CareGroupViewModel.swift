// CareCoordinator/ViewModels/CareGroupViewModel.swift
import Foundation
import Observation

@Observable
final class CareGroupViewModel {
    var careGroup: CareGroup?
    var isLoading = false
    var errorMessage: String?

    private let repository: CareGroupRepository

    init(repository: CareGroupRepository = CareGroupRepository()) {
        self.repository = repository
    }

    func createCareGroup(name: String, privacyMode: PrivacyMode, shiftStart: String, shiftEnd: String) async {
        isLoading = true
        errorMessage = nil
        do {
            careGroup = try await repository.create(
                name: name, privacyMode: privacyMode,
                shiftStart: shiftStart, shiftEnd: shiftEnd
            )
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadCareGroups() async {
        do {
            careGroup = try await repository.fetchForCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
