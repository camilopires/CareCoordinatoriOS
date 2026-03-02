// CareCoordinator/Views/Settings/CalendarSyncView.swift
import SwiftUI

struct CalendarSyncView: View {
    @State private var isSyncEnabled = false
    @State private var hasPermission = false
    @State private var isSyncing = false
    @State private var lastSyncDate: Date?
    @State private var errorMessage: String?

    let careGroupId: UUID
    let shifts: [Shift]
    let carerNames: [UUID: String]?

    private let calendarService = CalendarSyncService()

    var body: some View {
        Form {
            Section {
                Toggle("Sync Shifts to Calendar", isOn: $isSyncEnabled)
                    .onChange(of: isSyncEnabled) { _, newValue in
                        if newValue {
                            Task { await enableSync() }
                        } else {
                            Task { await disableSync() }
                        }
                    }
            } footer: {
                Text("Creates a 'CareCoordinator' calendar with your scheduled shifts. Changes in the app automatically update your calendar.")
            }

            if isSyncEnabled && hasPermission {
                Section("Sync Status") {
                    if isSyncing {
                        HStack {
                            ProgressView()
                            Text("Syncing...")
                                .padding(.leading, 8)
                        }
                    } else if let lastSync = lastSyncDate {
                        HStack {
                            Text("Last synced")
                            Spacer()
                            Text(lastSync.formatted(.relative(presentation: .named)))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Sync Now") {
                        Task { await performSync() }
                    }
                    .disabled(isSyncing)
                }
            }

            if !hasPermission && isSyncEnabled {
                Section {
                    Label("Calendar access required", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.orange)

                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }

            if let error = errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Calendar Sync")
        .onAppear {
            hasPermission = calendarService.hasAccess
        }
    }

    // MARK: - Actions

    private func enableSync() async {
        hasPermission = await calendarService.requestAccess()
        if hasPermission {
            await performSync()
        } else {
            isSyncEnabled = false
        }
    }

    private func disableSync() async {
        do {
            try calendarService.removeAllEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performSync() async {
        isSyncing = true
        errorMessage = nil
        do {
            try await calendarService.syncShifts(shifts, carerNames: carerNames)
            lastSyncDate = Date()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSyncing = false
    }
}
