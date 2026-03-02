// CareCoordinator/Repositories/ShiftNoteRepository.swift
import CryptoKit
import Foundation
import Supabase

final class ShiftNoteRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Create Note (Encrypted)

    func createNote(
        shiftId: UUID,
        careGroupId: UUID,
        carerId: UUID,
        content: String,
        groupKey: SymmetricKey
    ) async throws -> ShiftNote {
        let contentData = Data(content.utf8)
        let encryptedData = try CryptoService.encrypt(data: contentData, using: groupKey)
        let encryptedBase64 = encryptedData.base64EncodedString()

        struct InsertPayload: Encodable {
            let shift_id: UUID
            let care_group_id: UUID
            let carer_id: UUID
            let encrypted_content: String
        }

        return try await client
            .from("shift_notes")
            .insert(InsertPayload(
                shift_id: shiftId,
                care_group_id: careGroupId,
                carer_id: carerId,
                encrypted_content: encryptedBase64
            ))
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Fetch Notes

    func fetchNotes(shiftId: UUID) async throws -> [ShiftNote] {
        try await client
            .from("shift_notes")
            .select()
            .eq("shift_id", value: shiftId)
            .order("created_at", ascending: true)
            .execute()
            .value
    }

    // MARK: - Decrypt Note

    func decryptNote(note: ShiftNote, groupKey: SymmetricKey) throws -> String {
        guard let encryptedData = Data(base64Encoded: note.content) else {
            throw DecryptionError.invalidBase64
        }
        let decryptedData = try CryptoService.decrypt(data: encryptedData, using: groupKey)
        guard let text = String(data: decryptedData, encoding: .utf8) else {
            throw DecryptionError.invalidUTF8
        }
        return text
    }
}

// MARK: - Errors

extension ShiftNoteRepository {
    enum DecryptionError: Error, LocalizedError {
        case invalidBase64
        case invalidUTF8

        var errorDescription: String? {
            switch self {
            case .invalidBase64:
                return "Failed to decode encrypted content."
            case .invalidUTF8:
                return "Decrypted data is not valid text."
            }
        }
    }
}
