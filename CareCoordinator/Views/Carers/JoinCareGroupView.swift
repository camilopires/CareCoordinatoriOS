// CareCoordinator/Views/Carers/JoinCareGroupView.swift
import SwiftUI

struct JoinCareGroupView: View {
    @State private var code = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var isError = false
    private let repository = InvitationRepository()

    var body: some View {
        VStack(spacing: 24) {
            Text("Join a Care Group")
                .font(.title2.bold())

            Text("Enter the invite code your client shared with you")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("Invite Code", text: $code)
                .font(.system(size: 24, design: .monospaced))
                .multilineTextAlignment(.center)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding()
                .background(.fill.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            if let message {
                Text(message)
                    .foregroundStyle(isError ? .red : .green)
                    .font(.caption)
            }

            Button {
                Task { await submitCode() }
            } label: {
                if isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else {
                    Text("Request to Join").frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(code.count < 8 || isLoading)
        }
        .padding()
        .navigationTitle("Join Group")
    }

    private func submitCode() async {
        isLoading = true
        message = nil
        do {
            guard let invitation = try await repository.lookupInvitation(code: code.uppercased()) else {
                message = "Invalid or expired invite code"
                isError = true
                isLoading = false
                return
            }
            _ = try await repository.createJoinRequest(invitationId: invitation.id)
            message = "Request sent! Waiting for client approval."
            isError = false
        } catch {
            message = error.localizedDescription
            isError = true
        }
        isLoading = false
    }
}
