// CareCoordinator/Views/PTO/PTOListView.swift
import SwiftUI

struct PTOListView: View {
    @State var viewModel = PTOViewModel()
    let careGroupId: UUID
    let isClient: Bool
    let currentUserId: UUID

    var body: some View {
        List {
            if viewModel.ptoRequests.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "No PTO Requests",
                    systemImage: "calendar.badge.clock",
                    description: Text("No time-off requests have been submitted yet.")
                )
            }

            ForEach(viewModel.ptoRequests) { request in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(request.startDate) - \(request.endDate)")
                            .font(.headline)
                        Spacer()
                        PTOStatusBadge(status: request.status)
                    }

                    if let reason = request.reason {
                        Text(reason)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if isClient && request.status == .pending {
                        HStack {
                            Button("Approve") {
                                Task { await viewModel.approvePTO(request: request) }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)

                            Button("Deny") {
                                Task { await viewModel.denyPTO(request: request) }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.top, 4)
                    }

                    if let message = request.clientMessage {
                        Text("Client: \(message)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
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
        .navigationTitle("PTO Requests")
        .toolbar {
            if !isClient {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: PTORequestView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            viewModel.careGroupId = careGroupId
            viewModel.currentUserId = currentUserId
            viewModel.isClient = isClient
            await viewModel.loadPTORequests()
        }
    }
}

// MARK: - Status Badge

struct PTOStatusBadge: View {
    let status: PTOStatus

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch status {
        case .pending: return .yellow.opacity(0.2)
        case .approved: return .green.opacity(0.2)
        case .denied: return .red.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .denied: return .red
        }
    }
}
