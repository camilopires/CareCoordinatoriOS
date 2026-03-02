// CareCoordinator/Services/Auth/AppleSignInService.swift
import AuthenticationServices
import CryptoKit
import Foundation
import Supabase

final class AppleSignInService {
    private let client: SupabaseClient
    private var currentNonce: String?

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return nonce
    }

    func hashedNonce(from nonce: String) -> String {
        let data = Data(nonce.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func handleAuthorization(_ authorization: ASAuthorization) async throws -> Profile {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            throw AppleSignInError.missingCredentials
        }

        let session = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: identityToken,
                nonce: nonce
            )
        )

        // Update profile with Apple-provided name if available
        if let fullName = credential.fullName {
            let name = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            if !name.isEmpty {
                try await client
                    .from("profiles")
                    .update(["display_name": name])
                    .eq("id", value: session.user.id.uuidString)
                    .execute()
            }
        }

        let profile: Profile = try await client
            .from("profiles")
            .select()
            .eq("id", value: session.user.id.uuidString)
            .single()
            .execute()
            .value

        return profile
    }

    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }

    enum AppleSignInError: Error, LocalizedError {
        case missingCredentials

        var errorDescription: String? {
            switch self {
            case .missingCredentials:
                return "Missing Apple Sign In credentials. Please try again."
            }
        }
    }
}
