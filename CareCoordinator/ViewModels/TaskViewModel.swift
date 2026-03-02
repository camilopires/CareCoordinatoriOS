// CareCoordinator/ViewModels/TaskViewModel.swift
import Foundation

@Observable
final class TaskViewModel {
    var swapoverTemplate: [CareTask] = []
    var swapoverInstances: [CareTask] = []
    var generalTasks: [CareTask] = []
    var isLoading = false
    var errorMessage: String?

    // Form fields
    var newTaskTitle = ""
    var newTaskDescription = ""
    var newTaskDueDate = Date()
    var newTaskPriority: TaskPriority = .medium
    var newTaskIsRecurring = false
    var newTaskRecurrenceRule: String?

    private let repository: TaskRepository

    var careGroupId: UUID?
    var currentUserId: UUID?
    var isClient: Bool = false

    init(repository: TaskRepository = TaskRepository()) {
        self.repository = repository
    }

    // MARK: - Swapover Template

    func loadSwapoverTemplate() async {
        guard let careGroupId else { return }
        do {
            swapoverTemplate = try await repository.fetchSwapoverTemplate(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addTemplateItem(title: String, description: String?) async {
        guard let careGroupId else { return }
        do {
            let item = try await repository.createSwapoverTemplateItem(
                careGroupId: careGroupId,
                title: title,
                description: description,
                sortOrder: swapoverTemplate.count
            )
            swapoverTemplate.append(item)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTemplateItem(_ item: CareTask) async {
        do {
            try await repository.deleteTemplateItem(taskId: item.id)
            swapoverTemplate.removeAll { $0.id == item.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generateSwapoverInstance(assignedTo: UUID?, dueDate: Date) async {
        guard let careGroupId else { return }
        do {
            let instances = try await repository.generateSwapoverInstance(
                careGroupId: careGroupId,
                templateItems: swapoverTemplate,
                assignedTo: assignedTo,
                dueDate: dueDate
            )
            swapoverInstances.append(contentsOf: instances)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - General Tasks

    func loadGeneralTasks() async {
        guard let careGroupId else { return }
        isLoading = true
        do {
            generalTasks = try await repository.fetchGeneralTasks(careGroupId: careGroupId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func createGeneralTask() async {
        guard let careGroupId else { return }
        do {
            let task = try await repository.createGeneralTask(
                careGroupId: careGroupId,
                title: newTaskTitle,
                description: newTaskDescription.isEmpty ? nil : newTaskDescription,
                assignedTo: nil,
                dueDate: newTaskDueDate,
                priority: newTaskPriority,
                isRecurring: newTaskIsRecurring,
                recurrenceRule: newTaskRecurrenceRule
            )
            generalTasks.append(task)
            // Reset form
            newTaskTitle = ""
            newTaskDescription = ""
            newTaskPriority = .medium
            newTaskIsRecurring = false
            newTaskRecurrenceRule = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompletion(task: CareTask) async {
        do {
            let newState = !task.completed
            try await repository.toggleTaskCompletion(
                taskId: task.id,
                completed: newState,
                completedBy: newState ? currentUserId : nil
            )
            // Update local state
            if let index = generalTasks.firstIndex(where: { $0.id == task.id }) {
                generalTasks[index].completed = newState
            }
            if let index = swapoverInstances.firstIndex(where: { $0.id == task.id }) {
                swapoverInstances[index].completed = newState
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(_ task: CareTask) async {
        do {
            try await repository.deleteTask(taskId: task.id)
            generalTasks.removeAll { $0.id == task.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
