// CareCoordinator/Views/Schedule/AvailabilityView.swift
import SwiftUI

struct AvailabilityView: View {
    @State private var availability: [CarerAvailability] = []
    @State private var showingAddSheet = false
    @State private var newDate = Date()
    @State private var newStartTime = Date()
    @State private var newEndTime = Date()

    let carerId: UUID
    let careGroupId: UUID
    private let repository = AvailabilityRepository()

    var body: some View {
        List {
            if availability.isEmpty {
                ContentUnavailableView("No Availability Set", systemImage: "calendar.badge.plus",
                    description: Text("Mark dates you're available for extra shifts."))
            }

            ForEach(availability) { slot in
                VStack(alignment: .leading, spacing: 2) {
                    Text(slot.date)
                        .font(.headline)
                    if let startTime = slot.startTime, let endTime = slot.endTime {
                        Text("\(startTime) - \(endTime)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { indices in
                for index in indices {
                    let slot = availability[index]
                    Task {
                        try? await repository.deleteAvailability(id: slot.id)
                        availability.remove(at: index)
                    }
                }
            }
        }
        .navigationTitle("My Availability")
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
                    DatePicker("Date", selection: $newDate, displayedComponents: .date)
                    DatePicker("Start Time", selection: $newStartTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $newEndTime, displayedComponents: .hourAndMinute)
                }
                .navigationTitle("Add Availability")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task {
                                if let slot = try? await repository.submitAvailability(
                                    carerId: carerId,
                                    careGroupId: careGroupId,
                                    date: newDate,
                                    startTime: newStartTime,
                                    endTime: newEndTime
                                ) {
                                    availability.append(slot)
                                    showingAddSheet = false
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            availability = (try? await repository.fetchMyAvailability(carerId: carerId)) ?? []
        }
    }
}
