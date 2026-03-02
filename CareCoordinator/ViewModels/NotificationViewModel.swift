// CareCoordinator/ViewModels/NotificationViewModel.swift
import Foundation

@Observable
final class NotificationViewModel {
    var notifications: [CareNotification] = []
    var unreadCount: Int = 0
    var isLoading = false
    var errorMessage: String?

    private let repository: NotificationRepository
    var currentUserId: UUID?

    init(repository: NotificationRepository = NotificationRepository()) {
        self.repository = repository
    }

    func loadNotifications() async {
        guard let userId = currentUserId else { return }
        isLoading = true
        do {
            notifications = try await repository.fetchNotifications(userId: userId)
            unreadCount = notifications.filter { !$0.read }.count
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func markAsRead(_ notification: CareNotification) async {
        guard !notification.read else { return }
        do {
            try await repository.markAsRead(notificationId: notification.id)
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].read = true
                unreadCount = max(0, unreadCount - 1)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllAsRead() async {
        guard let userId = currentUserId else { return }
        do {
            try await repository.markAllAsRead(userId: userId)
            for i in notifications.indices {
                notifications[i].read = true
            }
            unreadCount = 0
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
