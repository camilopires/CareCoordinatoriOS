// CareCoordinator/Views/Schedule/ScheduleView.swift
import SwiftUI

struct ScheduleView: View {
    @Environment(ScheduleViewModel.self) private var scheduleVM
    let careGroupId: UUID
    @State private var selectedDate = Date()
    @State private var viewMode: ScheduleViewModel.ViewMode = .list

    var body: some View {
        VStack {
            Picker("View", selection: $viewMode) {
                ForEach(ScheduleViewModel.ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch viewMode {
            case .calendar:
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding(.horizontal)

                shiftsForSelectedDate
            case .list:
                ShiftListView(shifts: scheduleVM.shifts)
            }
        }
        .navigationTitle("Schedule")
        .overlay {
            if scheduleVM.isLoading {
                ProgressView()
            }
        }
        .task {
            await scheduleVM.loadSchedule(careGroupId: careGroupId)
        }
    }

    @ViewBuilder
    private var shiftsForSelectedDate: some View {
        let formatter = {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            return f
        }()
        let dateStr = formatter.string(from: selectedDate)
        let dayShifts = scheduleVM.shifts.filter { $0.date == dateStr }

        if dayShifts.isEmpty {
            ContentUnavailableView(
                "No Shifts",
                systemImage: "calendar.badge.exclamationmark",
                description: Text("No shifts scheduled for this date")
            )
        } else {
            List(dayShifts) { shift in
                NavigationLink {
                    ShiftDetailView(shift: shift)
                } label: {
                    ShiftRowView(shift: shift)
                }
            }
        }
    }
}
