// CareCoordinator/Services/Crypto/CryptoService.swift
import CryptoKit
import Foundation

enum CryptoService {

    // MARK: - Key Pair Management

    static func generateKeyPair() -> Curve25519.KeyAgreement.PrivateKey {
        Curve25519.KeyAgreement.PrivateKey()
    }

    static func savePrivateKey(_ key: Curve25519.KeyAgreement.PrivateKey, userId: String) throws {
        try KeychainService.save(data: key.rawRepresentation, account: "private-key-\(userId)")
    }

    static func loadPrivateKey(userId: String) throws -> Curve25519.KeyAgreement.PrivateKey {
        let data = try KeychainService.load(account: "private-key-\(userId)")
        return try Curve25519.KeyAgreement.PrivateKey(rawRepresentation: data)
    }

    // MARK: - Group Key Management

    static func generateGroupKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }

    static func saveGroupKey(_ key: SymmetricKey, groupId: String) throws {
        let data = key.withUnsafeBytes { Data($0) }
        try KeychainService.save(data: data, account: "group-key-\(groupId)")
    }

    static func loadGroupKey(groupId: String) throws -> SymmetricKey {
        let data = try KeychainService.load(account: "group-key-\(groupId)")
        return SymmetricKey(data: data)
    }

    // MARK: - AES-GCM Encryption/Decryption

    static func encrypt(data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw CryptoError.encryptionFailed
        }
        return combined
    }

    static func decrypt(data: Data, using key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    // MARK: - Key Exchange (share group key with a carer)

    static func encryptGroupKey(
        groupKey: SymmetricKey,
        senderPrivateKey: Curve25519.KeyAgreement.PrivateKey,
        recipientPublicKey: Curve25519.KeyAgreement.PublicKey
    ) throws -> Data {
        let sharedSecret = try senderPrivateKey.sharedSecretFromKeyAgreement(with: recipientPublicKey)
        let derivedKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "CareCoordinator-GroupKeyExchange".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        let groupKeyData = groupKey.withUnsafeBytes { Data($0) }
        return try encrypt(data: groupKeyData, using: derivedKey)
    }

    static func decryptGroupKey(
        encryptedGroupKey: Data,
        recipientPrivateKey: Curve25519.KeyAgreement.PrivateKey,
        senderPublicKey: Curve25519.KeyAgreement.PublicKey
    ) throws -> SymmetricKey {
        let sharedSecret = try recipientPrivateKey.sharedSecretFromKeyAgreement(with: senderPublicKey)
        let derivedKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: "CareCoordinator-GroupKeyExchange".data(using: .utf8)!,
            sharedInfo: Data(),
            outputByteCount: 32
        )
        let groupKeyData = try decrypt(data: encryptedGroupKey, using: derivedKey)
        return SymmetricKey(data: groupKeyData)
    }

    enum CryptoError: Error, LocalizedError {
        case encryptionFailed

        var errorDescription: String? {
            switch self {
            case .encryptionFailed:
                return "Encryption failed: could not produce sealed box."
            }
        }
    }
}
