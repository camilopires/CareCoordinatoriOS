// CareCoordinator/Views/PTO/OpenShiftsView.swift
import SwiftUI

struct OpenShiftsView: View {
    @State var viewModel = PTOViewModel()
    let careGroupId: UUID
    let currentUserId: UUID
    let isClient: Bool

    var body: some View {
        List {
            if viewModel.openShiftOffers.isEmpty {
                ContentUnavailableView(
                    "No Open Shifts",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("No shifts currently need coverage.")
                )
            }

            ForEach(viewModel.openShiftOffers) { offer in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text("Shift \(offer.shiftId.uuidString.prefix(8))...")
                            .font(.headline)
                    }

                    Text("Status: \(offer.status.rawValue.capitalized)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let acceptedBy = offer.acceptedBy {
                        Text("Accepted by: \(acceptedBy.uuidString.prefix(8))...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        // Carers can accept pending offers
                        if !isClient && offer.status == .pending {
                            Button("Accept This Shift") {
                                Task { await viewModel.acceptShift(offer: offer) }
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        // Clients can confirm accepted offers
                        if isClient && offer.status == .accepted {
                            Button("Confirm") {
                                Task { await viewModel.confirmAcceptedOffer(offer: offer) }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 4)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Open Shifts")
        .task {
            viewModel.careGroupId = careGroupId
            viewModel.currentUserId = currentUserId
            viewModel.isClient = isClient
            await viewModel.loadOpenOffers()
        }
    }
}
