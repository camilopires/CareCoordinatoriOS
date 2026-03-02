// CareCoordinator/ViewModels/CarePlanViewModel.swift
import CryptoKit
import Foundation
import Observation

@Observable
final class CarePlanViewModel {
    var carePlans: [CarePlan] = []
    var isLoading = false
    var errorMessage: String?
    var decryptedPDFData: Data?
    var isUploading = false

    private let repository: CarePlanRepository

    var careGroupId: UUID?
    var currentUserId: UUID?

    init(repository: CarePlanRepository = CarePlanRepository()) {
        self.repository = repository
    }

    // MARK: - Load

    func loadCarePlans() async {
        guard let careGroupId else { return }
        isLoading = true
        errorMessage = nil

        do {
            carePlans = try await repository.fetchCarePlans(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Upload

    func uploadPDF(title: String, data: Data) async {
        guard let careGroupId, let currentUserId else { return }
        isUploading = true
        errorMessage = nil

        do {
            let groupKey = try loadGroupKey()
            let newPlan = try await repository.uploadCarePlan(
                title: title,
                pdfData: data,
                careGroupId: careGroupId,
                uploadedBy: currentUserId,
                groupKey: groupKey
            )
            carePlans.insert(newPlan, at: 0)
        } catch {
            errorMessage = "Upload failed: \(error.localizedDescription)"
        }

        isUploading = false
    }

    // MARK: - Open (Download + Decrypt)

    func openCarePlan(_ carePlan: CarePlan) async {
        isLoading = true
        errorMessage = nil

        do {
            let groupKey = try loadGroupKey()
            decryptedPDFData = try await repository.downloadAndDecrypt(
                carePlan: carePlan,
                groupKey: groupKey
            )
        } catch {
            errorMessage = "Failed to open: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Delete

    func deleteCarePlan(_ carePlan: CarePlan) async {
        errorMessage = nil

        do {
            try await repository.deleteCarePlan(carePlan)
            carePlans.removeAll { $0.id == carePlan.id }
        } catch {
            errorMessage = "Delete failed: \(error.localizedDescription)"
        }
    }

    // MARK: - Private

    private func loadGroupKey() throws -> SymmetricKey {
        guard let careGroupId else {
            throw CarePlanError.groupKeyNotFound
        }
        let data = try KeychainService.load(account: "group-key-\(careGroupId.uuidString)")
        return SymmetricKey(data: data)
    }
}

// MARK: - Errors

enum CarePlanError: Error, LocalizedError {
    case groupKeyNotFound

    var errorDescription: String? {
        switch self {
        case .groupKeyNotFound:
            return "Encryption key not found. Please rejoin the care group."
        }
    }
}
