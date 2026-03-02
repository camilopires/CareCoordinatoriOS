// CareCoordinator/Views/Auth/SignUpView.swift
import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var role: UserRole = .client

    var body: some View {
        Form {
            Section("Your Details") {
                TextField("Display Name", text: $displayName)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("Password (8+ characters)", text: $password)
                    .textContentType(.newPassword)
            }

            Section("I am a...") {
                Picker("Role", selection: $role) {
                    Text("Client (managing care)").tag(UserRole.client)
                    Text("Carer (providing care)").tag(UserRole.carer)
                }
                .pickerStyle(.inline)
            }

            if let error = authVM.errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task {
                        await authVM.signUp(
                            email: email, password: password,
                            displayName: displayName, role: role
                        )
                        if authVM.currentProfile != nil { dismiss() }
                    }
                } label: {
                    if authVM.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(email.isEmpty || password.count < 8 || displayName.isEmpty || authVM.isLoading)
            }
        }
        .navigationTitle("Sign Up")
    }
}
