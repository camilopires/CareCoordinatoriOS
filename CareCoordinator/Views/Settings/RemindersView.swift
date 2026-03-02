// CareCoordinator/Views/Settings/RemindersView.swift
import SwiftUI

struct RemindersView: View {
    @State private var reminders: [Reminder] = []
    @State private var showingAddSheet = false
    @State private var errorMessage: String?

    // Add form state
    @State private var newTitle = ""
    @State private var newTime = Date()
    @State private var newIsRecurring = false
    @State private var newRecurrenceRule = "daily"

    let careGroupId: UUID
    let currentUserId: UUID

    private let repository = ReminderRepository()

    var body: some View {
        List {
            if reminders.isEmpty {
                ContentUnavailableView("No Reminders", systemImage: "bell.slash",
                    description: Text("Set up medication or appointment reminders."))
            }

            ForEach(reminders) { reminder in
                VStack(alignment: .leading, spacing: 4) {
                    Text(reminder.title)
                        .font(.headline)
                    Text(reminder.time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if reminder.isRecurring {
                        Label(reminder.recurrenceRule ?? "Recurring", systemImage: "repeat")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .onDelete { indices in
                for index in indices {
                    let reminder = reminders[index]
                    Task {
                        try? await repository.deleteReminder(reminderId: reminder.id)
                    }
                }
                reminders.remove(atOffsets: indices)
            }
        }
        .navigationTitle("Reminders")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddSheet = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            NavigationStack {
                Form {
                    TextField("Title (e.g., Medication)", text: $newTitle)
                    DatePicker("Time", selection: $newTime, displayedComponents: .hourAndMinute)
                    Toggle("Recurring", isOn: $newIsRecurring)
                    if newIsRecurring {
                        Picker("Frequency", selection: $newRecurrenceRule) {
                            Text("Daily").tag("daily")
                            Text("Weekly").tag("weekly")
                        }
                    }
                }
                .navigationTitle("Add Reminder")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task { await saveReminder() }
                        }
                        .disabled(newTitle.isEmpty)
                    }
                }
            }
        }
        .task {
            reminders = (try? await repository.fetchReminders(careGroupId: careGroupId)) ?? []
        }
    }

    // MARK: - Actions

    private func saveReminder() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let timeString = formatter.string(from: newTime)

        do {
            let reminder = try await repository.createReminder(
                careGroupId: careGroupId,
                title: newTitle,
                time: timeString,
                isRecurring: newIsRecurring,
                recurrenceRule: newIsRecurring ? newRecurrenceRule : nil,
                createdBy: currentUserId
            )
            reminders.append(reminder)
            showingAddSheet = false
            newTitle = ""
            newIsRecurring = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
