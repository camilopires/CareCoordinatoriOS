// CareCoordinator/Views/Settings/EmergencyContactsView.swift
import SwiftUI

struct EmergencyContactsView: View {
    @State private var contacts: [EmergencyContact] = []
    @State private var showingAddSheet = false
    @State private var errorMessage: String?

    @State private var newName = ""
    @State private var newPhone = ""
    @State private var newRelationship = ""

    let careGroupId: UUID
    let isClient: Bool

    private let repository = EmergencyContactRepository()

    var body: some View {
        List {
            if contacts.isEmpty {
                ContentUnavailableView("No Emergency Contacts", systemImage: "phone.badge.plus",
                    description: Text("Add emergency contacts for quick access."))
            }

            ForEach(contacts) { contact in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(contact.name)
                            .font(.headline)
                        if !contact.relationship.isEmpty {
                            Text(contact.relationship)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Quick-dial button
                    Link(destination: URL(string: "tel:\(contact.phone)")!) {
                        Image(systemName: "phone.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
            .onDelete { indices in
                guard isClient else { return }
                for index in indices {
                    let contact = contacts[index]
                    Task {
                        try? await repository.deleteContact(contactId: contact.id)
                    }
                }
                contacts.remove(atOffsets: indices)
            }
        }
        .navigationTitle("Emergency Contacts")
        .toolbar {
            if isClient {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddSheet = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    TextField("Name", text: $newName)
                    TextField("Phone", text: $newPhone)
                        .keyboardType(.phonePad)
                    TextField("Relationship (optional)", text: $newRelationship)
                }
                .navigationTitle("Add Contact")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task { await saveContact() }
                        }
                        .disabled(newName.isEmpty || newPhone.isEmpty)
                    }
                }
            }
        }
        .task {
            contacts = (try? await repository.fetchContacts(careGroupId: careGroupId)) ?? []
        }
    }

    // MARK: - Actions

    private func saveContact() async {
        do {
            let contact = try await repository.createContact(
                careGroupId: careGroupId,
                name: newName,
                phone: newPhone,
                relationship: newRelationship,
                sortOrder: contacts.count
            )
            contacts.append(contact)
            showingAddSheet = false
            newName = ""
            newPhone = ""
            newRelationship = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
