// CareCoordinator/Views/Tasks/GeneralTaskListView.swift
import SwiftUI

struct GeneralTaskListView: View {
    @State var viewModel = TaskViewModel()
    let careGroupId: UUID
    let currentUserId: UUID
    let isClient: Bool

    var body: some View {
        List {
            if viewModel.generalTasks.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No Tasks", systemImage: "checklist",
                    description: Text("Create a task to get started."))
            }

            Section("Active") {
                ForEach(viewModel.generalTasks.filter { !$0.completed }) { task in
                    TaskRowView(task: task) {
                        Task { await viewModel.toggleCompletion(task: task) }
                    }
                }
                .onDelete { indices in
                    let activeTasks = viewModel.generalTasks.filter { !$0.completed }
                    for index in indices {
                        Task { await viewModel.deleteTask(activeTasks[index]) }
                    }
                }
            }

            let completed = viewModel.generalTasks.filter { $0.completed }
            if !completed.isEmpty {
                Section("Completed") {
                    ForEach(completed) { task in
                        TaskRowView(task: task) {
                            Task { await viewModel.toggleCompletion(task: task) }
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                Section { Text(error).foregroundStyle(.red) }
            }
        }
        .navigationTitle("Tasks")
        .toolbar {
            if isClient {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: CreateTaskView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            viewModel.careGroupId = careGroupId
            viewModel.currentUserId = currentUserId
            viewModel.isClient = isClient
            await viewModel.loadGeneralTasks()
        }
    }
}
