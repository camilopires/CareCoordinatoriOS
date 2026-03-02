// CareCoordinator/Services/Auth/AuthService.swift
import Foundation
import Supabase

final class AuthService {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func signUp(email: String, password: String, displayName: String, role: UserRole) async throws -> Profile {
        let session = try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "display_name": .string(displayName),
                "role": .string(role.rawValue)
            ]
        )

        // Profile is auto-created by the DB trigger handle_new_user()
        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .single()
            .execute()
            .value

        return profile
    }

    func signIn(email: String, password: String) async throws -> Profile {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )

        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .single()
            .execute()
            .value

        return profile
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func currentSession() async throws -> Session {
        try await client.auth.session
    }

    func currentProfile() async throws -> Profile {
        let session = try await client.auth.session
        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .single()
            .execute()
            .value
        return profile
    }
}
