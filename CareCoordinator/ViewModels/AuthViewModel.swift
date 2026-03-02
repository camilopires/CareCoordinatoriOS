// CareCoordinator/ViewModels/AuthViewModel.swift
import Foundation
import Observation

enum AuthState: Equatable {
    case loading
    case unauthenticated
    case authenticated(Profile)
    case needsCareGroup(Profile)
}

@Observable
final class AuthViewModel {
    var authState: AuthState = .loading
    var errorMessage: String?
    var isLoading = false
    var careGroup: CareGroup?

    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
    }

    // MARK: - Computed Helpers

    var isAuthenticated: Bool {
        if case .authenticated = authState { return true }
        return false
    }

    var currentProfile: Profile? {
        switch authState {
        case .authenticated(let profile), .needsCareGroup(let profile):
            return profile
        default:
            return nil
        }
    }

    // MARK: - Actions

    func signUp(email: String, password: String, displayName: String, role: UserRole) async {
        isLoading = true
        errorMessage = nil
        do {
            let profile = try await authService.signUp(
                email: email, password: password,
                displayName: displayName, role: role
            )
            resolveAuthState(for: profile)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let profile = try await authService.signIn(email: email, password: password)
            resolveAuthState(for: profile)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signOut() async {
        do {
            try await authService.signOut()
            careGroup = nil
            authState = .unauthenticated
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func checkSession() async {
        authState = .loading
        do {
            let profile = try await authService.currentProfile()
            resolveAuthState(for: profile)
        } catch {
            authState = .unauthenticated
        }
    }

    // MARK: - Private

    private func resolveAuthState(for profile: Profile) {
        if profile.careGroupId != nil {
            authState = .authenticated(profile)
        } else {
            authState = .needsCareGroup(profile)
        }
    }
}
