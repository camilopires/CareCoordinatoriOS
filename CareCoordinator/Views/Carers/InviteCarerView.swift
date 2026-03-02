// CareCoordinator/Views/Carers/InviteCarerView.swift
import SwiftUI

struct InviteCarerView: View {
    let careGroupId: UUID
    @State private var invitation: Invitation?
    @State private var pendingRequests: [JoinRequest] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    private let repository = InvitationRepository()

    var body: some View {
        VStack(spacing: 24) {
            if let invitation {
                VStack(spacing: 16) {
                    Text("Invite Code")
                        .font(.headline)
                    Text(invitation.code)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .padding()
                        .background(.fill.tertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Share this code with your carer. It expires in 7 days.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    ShareLink(item: "Join my CareCoordinator group with code: \(invitation.code)") {
                        Label("Share Code", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Copy to Clipboard") {
                        UIPasteboard.general.string = invitation.code
                    }
                }
            } else {
                Button {
                    Task { await generateCode() }
                } label: {
                    if isLoading {
                        ProgressView()
                    } else {
                        Label("Generate Invite Code", systemImage: "person.badge.plus")
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            if !pendingRequests.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Pending Join Requests")
                        .font(.headline)

                    ForEach(pendingRequests) { request in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Carer ID: \(request.carerId.uuidString.prefix(8))...")
                                    .font(.subheadline)
                                Text("Requested \(request.createdAt, style: .relative) ago")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button("Approve") {
                                Task {
                                    await approveRequest(request)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)

                            Button("Deny") {
                                Task {
                                    await denyRequest(request)
                                }
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                }
            }

            if let error = errorMessage {
                Text(error).foregroundStyle(.red).font(.caption)
            }
        }
        .padding()
        .navigationTitle("Invite Carer")
        .task {
            await loadPendingRequests()
        }
    }

    private func generateCode() async {
        isLoading = true
        do {
            invitation = try await repository.createInvitation(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadPendingRequests() async {
        do {
            pendingRequests = try await repository.fetchPendingJoinRequests(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func approveRequest(_ request: JoinRequest) async {
        do {
            try await repository.approveJoinRequest(
                requestId: request.id,
                carerId: request.carerId,
                careGroupId: careGroupId
            )
            pendingRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func denyRequest(_ request: JoinRequest) async {
        do {
            try await repository.denyJoinRequest(requestId: request.id)
            pendingRequests.removeAll { $0.id == request.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
