// CareCoordinator/Views/Schedule/ShiftNotesView.swift
import CryptoKit
import SwiftUI

struct ShiftNotesView: View {
    let shiftId: UUID
    let careGroupId: UUID
    let currentUserId: UUID

    @State private var notes: [(note: ShiftNote, decryptedContent: String)] = []
    @State private var newNoteText = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let repository = ShiftNoteRepository()

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(notes, id: \.note.id) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.note.carerId == currentUserId ? "You" : "Carer")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(item.note.createdAt.formatted(.relative(presentation: .named)))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            Text(item.decryptedContent)
                                .font(.body)
                        }
                        .padding()
                        .background(
                            item.note.carerId == currentUserId
                                ? Color.blue.opacity(0.1)
                                : Color(.systemGray6)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }

            // Compose bar
            HStack {
                TextField("Leave a note for the next carer...", text: $newNoteText, axis: .vertical)
                    .lineLimit(1...4)
                    .textFieldStyle(.roundedBorder)

                Button {
                    Task { await sendNote() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Shift Notes")
        .task { await loadNotes() }
    }

    // MARK: - Data Loading

    private func loadNotes() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let groupKey = try loadGroupKey()
            let rawNotes = try await repository.fetchNotes(shiftId: shiftId)
            notes = rawNotes.compactMap { note in
                guard let decrypted = try? repository.decryptNote(note: note, groupKey: groupKey) else {
                    return nil
                }
                return (note: note, decryptedContent: decrypted)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func sendNote() async {
        let content = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }

        do {
            let groupKey = try loadGroupKey()
            let note = try await repository.createNote(
                shiftId: shiftId,
                careGroupId: careGroupId,
                carerId: currentUserId,
                content: content,
                groupKey: groupKey
            )
            notes.append((note: note, decryptedContent: content))
            newNoteText = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadGroupKey() throws -> SymmetricKey {
        let data = try KeychainService.load(account: "group-key-\(careGroupId.uuidString)")
        return SymmetricKey(data: data)
    }
}
