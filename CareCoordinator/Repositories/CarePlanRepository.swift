// CareCoordinator/Repositories/CarePlanRepository.swift
import CryptoKit
import Foundation
import Supabase

final class CarePlanRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseManager.client) {
        self.client = client
    }

    // MARK: - Upload (E2E Encrypted)

    /// Encrypts a PDF using the group's symmetric key and uploads to Supabase Storage.
    /// Inserts a metadata row in the `care_plans` table.
    func uploadCarePlan(
        title: String,
        pdfData: Data,
        careGroupId: UUID,
        uploadedBy: UUID,
        groupKey: SymmetricKey
    ) async throws -> CarePlan {
        // 1. Encrypt the PDF data using AES-GCM via CryptoService
        let encryptedData = try CryptoService.encrypt(data: pdfData, using: groupKey)

        // 2. Upload encrypted blob to Supabase Storage
        let fileName = "\(careGroupId.uuidString)/\(UUID().uuidString).enc"
        try await client.storage
            .from("care-plans")
            .upload(
                path: fileName,
                file: encryptedData,
                options: FileOptions(contentType: "application/octet-stream")
            )

        // 3. Insert metadata row
        struct InsertPayload: Encodable {
            let care_group_id: String
            let title: String
            let storage_path: String
            let file_size: Int64
            let uploaded_by: String
        }

        let carePlan: CarePlan = try await client
            .from("care_plans")
            .insert(InsertPayload(
                care_group_id: careGroupId.uuidString,
                title: title,
                storage_path: fileName,
                file_size: Int64(encryptedData.count),
                uploaded_by: uploadedBy.uuidString
            ))
            .select()
            .single()
            .execute()
            .value

        return carePlan
    }

    // MARK: - Fetch

    /// Fetches all care plan metadata for a care group, sorted newest first.
    func fetchCarePlans(careGroupId: UUID) async throws -> [CarePlan] {
        try await client
            .from("care_plans")
            .select()
            .eq("care_group_id", value: careGroupId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    // MARK: - Download & Decrypt

    /// Downloads the encrypted blob from Storage and decrypts it with the group key.
    func downloadAndDecrypt(
        carePlan: CarePlan,
        groupKey: SymmetricKey
    ) async throws -> Data {
        let encryptedData = try await client.storage
            .from("care-plans")
            .download(path: carePlan.storagePath)

        return try CryptoService.decrypt(data: encryptedData, using: groupKey)
    }

    // MARK: - Delete

    /// Deletes the encrypted file from Storage and removes the metadata row.
    func deleteCarePlan(_ carePlan: CarePlan) async throws {
        // Delete from storage
        try await client.storage
            .from("care-plans")
            .remove(paths: [carePlan.storagePath])

        // Delete metadata row
        try await client
            .from("care_plans")
            .delete()
            .eq("id", value: carePlan.id.uuidString)
            .execute()
    }
}
