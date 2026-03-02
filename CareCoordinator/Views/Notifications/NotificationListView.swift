// CareCoordinator/Views/Notifications/NotificationListView.swift
import SwiftUI

struct NotificationListView: View {
    @State var viewModel = NotificationViewModel()
    let currentUserId: UUID

    var body: some View {
        List {
            if viewModel.notifications.isEmpty && !viewModel.isLoading {
                ContentUnavailableView("No Notifications", systemImage: "bell.slash",
                    description: Text("You're all caught up."))
            }

            ForEach(viewModel.notifications) { notification in
                NotificationRowView(notification: notification)
                    .onTapGesture {
                        Task { await viewModel.markAsRead(notification) }
                    }
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if viewModel.unreadCount > 0 {
                    Button("Mark All Read") {
                        Task { await viewModel.markAllAsRead() }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadNotifications()
        }
        .task {
            viewModel.currentUserId = currentUserId
            await viewModel.loadNotifications()
        }
    }
}
