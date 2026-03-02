// CareCoordinator/ViewModels/PTOViewModel.swift
import Foundation
import Observation

@Observable
final class PTOViewModel {
    var ptoRequests: [PTORequest] = []
    var openShiftOffers: [ShiftOffer] = []
    var isLoading = false
    var errorMessage: String?

    // Form fields for new PTO request
    var startDate = Date()
    var endDate = Date()
    var reason = ""

    private let ptoRepository: PTORepository
    private let shiftOfferRepository: ShiftOfferRepository
    private let shiftRepository: ShiftRepository

    var careGroupId: UUID?
    var currentUserId: UUID?
    var isClient: Bool = false

    init(
        ptoRepository: PTORepository = PTORepository(),
        shiftOfferRepository: ShiftOfferRepository = ShiftOfferRepository(),
        shiftRepository: ShiftRepository = ShiftRepository()
    ) {
        self.ptoRepository = ptoRepository
        self.shiftOfferRepository = shiftOfferRepository
        self.shiftRepository = shiftRepository
    }

    // MARK: - Date Formatting

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - Load Data

    func loadPTORequests() async {
        guard let careGroupId else { return }
        isLoading = true
        errorMessage = nil

        do {
            if isClient {
                ptoRequests = try await ptoRepository.fetchPTORequests(careGroupId: careGroupId)
            } else if let userId = currentUserId {
                ptoRequests = try await ptoRepository.fetchMyPTORequests(carerId: userId)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadOpenOffers() async {
        guard let careGroupId else { return }
        do {
            openShiftOffers = try await shiftOfferRepository.fetchOpenOffers(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Carer Actions

    func submitPTORequest() async {
        guard let currentUserId, let careGroupId else { return }
        isLoading = true
        errorMessage = nil

        do {
            let newRequest = try await ptoRepository.createPTORequest(
                carerId: currentUserId,
                careGroupId: careGroupId,
                startDate: Self.dateFormatter.string(from: startDate),
                endDate: Self.dateFormatter.string(from: endDate),
                reason: reason.isEmpty ? nil : reason
            )
            ptoRequests.append(newRequest)
            // Reset form
            reason = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func acceptShift(offer: ShiftOffer) async {
        guard let currentUserId else { return }
        do {
            try await shiftOfferRepository.acceptShift(offerId: offer.id, carerId: currentUserId)
            await loadOpenOffers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Client Actions

    func approvePTO(request: PTORequest) async {
        guard let careGroupId else { return }
        do {
            try await ptoRepository.approvePTO(requestId: request.id)

            // Mark affected shifts as needing cover
            let affectedShifts = try await shiftRepository.fetchShifts(
                careGroupId: careGroupId,
                from: request.startDate,
                to: request.endDate
            ).filter { $0.carerId == request.carerId }

            for shift in affectedShifts {
                _ = try await shiftRepository.updateShift(
                    id: shift.id,
                    carerId: nil,
                    status: .needingCover
                )
            }

            await loadPTORequests()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func denyPTO(request: PTORequest) async {
        do {
            try await ptoRepository.denyPTO(requestId: request.id)
            await loadPTORequests()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func broadcastOpenShift(shiftId: UUID) async {
        do {
            _ = try await shiftOfferRepository.createShiftOffer(shiftId: shiftId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmAcceptedOffer(offer: ShiftOffer) async {
        guard let acceptedBy = offer.acceptedBy else { return }
        do {
            try await shiftOfferRepository.confirmAcceptedOffer(
                offerId: offer.id,
                shiftId: offer.shiftId,
                newCarerId: acceptedBy
            )
            await loadOpenOffers()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
