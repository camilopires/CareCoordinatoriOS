// CareCoordinator/Views/Dashboard/ClientDashboardView.swift
import SwiftUI

struct ClientDashboardView: View {
    let profile: Profile
    let careGroup: CareGroup

    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var notificationViewModel = NotificationViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Welcome header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Welcome back")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(profile.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()

                        NavigationLink(destination: NotificationListView(currentUserId: profile.id)) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.title3)
                                if notificationViewModel.unreadCount > 0 {
                                    Text("\(notificationViewModel.unreadCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Today's shift card
                    DashboardCard(title: "Today's Shift", icon: "calendar") {
                        if let todayShift = scheduleViewModel.todayShift {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(todayShift.startTime) - \(todayShift.endTime)")
                                    .font(.headline)
                                Text("Status: \(todayShift.status.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("No shift today")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Quick actions grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickActionCard(
                            title: "Schedule",
                            icon: "calendar",
                            color: .blue,
                            destination: AnyView(
                                ScheduleView(careGroupId: careGroup.id)
                                    .environment(scheduleViewModel)
                            )
                        )

                        QuickActionCard(
                            title: "Carers",
                            icon: "person.2",
                            color: .green,
                            destination: AnyView(InviteCarerView(careGroupId: careGroup.id))
                        )

                        QuickActionCard(
                            title: "Tasks",
                            icon: "checklist",
                            color: .orange,
                            destination: AnyView(GeneralTaskListView(
                                careGroupId: careGroup.id,
                                currentUserId: profile.id,
                                isClient: true
                            ))
                        )

                        QuickActionCard(
                            title: "Care Plans",
                            icon: "doc.text",
                            color: .purple,
                            destination: AnyView(CarePlanListView(
                                careGroupId: careGroup.id,
                                currentUserId: profile.id,
                                isClient: true
                            ))
                        )

                        QuickActionCard(
                            title: "PTO",
                            icon: "calendar.badge.clock",
                            color: .red,
                            destination: AnyView(PTOListView(
                                careGroupId: careGroup.id,
                                isClient: true,
                                currentUserId: profile.id
                            ))
                        )

                        QuickActionCard(
                            title: "Care-y",
                            icon: "brain",
                            color: .pink,
                            destination: AnyView(CareyChatView(
                                profile: profile,
                                careGroup: careGroup,
                                shifts: scheduleViewModel.shifts,
                                tasks: [],
                                carerNames: nil
                            ))
                        )
                    }
                    .padding(.horizontal)

                    // Recent activity
                    DashboardCard(title: "Recent Activity", icon: "clock") {
                        NavigationLink(destination: ActivityLogView(careGroupId: careGroup.id)) {
                            Text("View activity log")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .task {
                await scheduleViewModel.loadSchedule(careGroupId: careGroup.id)
                notificationViewModel.currentUserId = profile.id
                await notificationViewModel.loadNotifications()
            }
        }
    }
}

// MARK: - Supporting Components

struct DashboardCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
