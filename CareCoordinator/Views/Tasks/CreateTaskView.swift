// CareCoordinator/Views/Tasks/CreateTaskView.swift
import SwiftUI

struct CreateTaskView: View {
    @Bindable var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Task Details") {
                TextField("Title", text: $viewModel.newTaskTitle)
                TextField("Description (optional)", text: $viewModel.newTaskDescription, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("Priority & Date") {
                Picker("Priority", selection: $viewModel.newTaskPriority) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue.capitalized).tag(priority)
                    }
                }
                DatePicker("Due Date", selection: $viewModel.newTaskDueDate, displayedComponents: .date)
            }

            Section {
                Toggle("Recurring", isOn: $viewModel.newTaskIsRecurring)
                if viewModel.newTaskIsRecurring {
                    Picker("Frequency", selection: Binding(
                        get: { viewModel.newTaskRecurrenceRule ?? "daily" },
                        set: { viewModel.newTaskRecurrenceRule = $0 }
                    )) {
                        Text("Daily").tag("daily")
                        Text("Weekly").tag("weekly")
                        Text("Monthly").tag("monthly")
                    }
                }
            }

            Section {
                Button("Create Task") {
                    Task {
                        await viewModel.createGeneralTask()
                        if viewModel.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.newTaskTitle.isEmpty)
            }
        }
        .navigationTitle("New Task")
    }
}
