// CareCoordinator/Views/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    let profile: Profile
    let careGroup: CareGroup
    let isClient: Bool
    let onSignOut: () -> Void

    var body: some View {
        Form {
            Section("Profile") {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading) {
                        Text(profile.displayName)
                            .font(.headline)
                        Text(profile.role.rawValue.capitalized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if isClient {
                Section("Care Group") {
                    HStack {
                        Text("Privacy Mode")
                        Spacer()
                        Text(careGroup.privacyMode.rawValue.capitalized)
                            .foregroundStyle(.secondary)
                    }

                    NavigationLink("Manage Carers") {
                        InviteCarerView(careGroupId: careGroup.id)
                    }

                    NavigationLink("Swapover Checklist Template") {
                        SwapoverTemplateView(careGroupId: careGroup.id)
                    }
                }

                Section("Care") {
                    NavigationLink("Emergency Contacts") {
                        EmergencyContactsView(careGroupId: careGroup.id, isClient: true)
                    }

                    NavigationLink("Reminders") {
                        RemindersView(careGroupId: careGroup.id, currentUserId: profile.id)
                    }
                }
            }

            Section("Sync") {
                NavigationLink("Calendar Sync") {
                    CalendarSyncView(
                        careGroupId: careGroup.id,
                        shifts: [],
                        carerNames: nil
                    )
                }

                NavigationLink("Notification Preferences") {
                    NotificationPreferencesView()
                }
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    onSignOut()
                }
            }

            Section {
                HStack {
                    Spacer()
                    Text("CareCoordinator v1.0")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
            }
        }
        .navigationTitle("Settings")
    }
}

struct NotificationPreferencesView: View {
    @State private var shiftReminders = true
    @State private var ptoAlerts = true
    @State private var taskAssignments = true

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Shift Reminders", isOn: $shiftReminders)
                Toggle("PTO Request Alerts", isOn: $ptoAlerts)
                Toggle("Task Assignments", isOn: $taskAssignments)
            }
        }
        .navigationTitle("Notifications")
    }
}
