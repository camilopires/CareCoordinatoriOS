// CareCoordinator/Views/Dashboard/CarerDashboardView.swift
import SwiftUI

struct CarerDashboardView: View {
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

                    // Next shift card
                    DashboardCard(title: "Your Next Shift", icon: "calendar") {
                        if let nextShift = scheduleViewModel.nextShift {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(nextShift.date)
                                    .font(.headline)
                                Text("\(nextShift.startTime) - \(nextShift.endTime)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("No upcoming shifts")
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Quick actions
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickActionCard(
                            title: "My Schedule",
                            icon: "calendar",
                            color: .blue,
                            destination: AnyView(
                                ScheduleView(careGroupId: careGroup.id)
                                    .environment(scheduleViewModel)
                            )
                        )

                        QuickActionCard(
                            title: "My Tasks",
                            icon: "checklist",
                            color: .orange,
                            destination: AnyView(GeneralTaskListView(
                                careGroupId: careGroup.id,
                                currentUserId: profile.id,
                                isClient: false
                            ))
                        )

                        QuickActionCard(
                            title: "Care Plans",
                            icon: "doc.text",
                            color: .purple,
                            destination: AnyView(CarePlanListView(
                                careGroupId: careGroup.id,
                                currentUserId: profile.id,
                                isClient: false
                            ))
                        )

                        QuickActionCard(
                            title: "Request PTO",
                            icon: "calendar.badge.clock",
                            color: .red,
                            destination: AnyView(PTOListView(
                                careGroupId: careGroup.id,
                                isClient: false,
                                currentUserId: profile.id
                            ))
                        )

                        QuickActionCard(
                            title: "Open Shifts",
                            icon: "hand.raised",
                            color: .green,
                            destination: AnyView(OpenShiftsView(
                                careGroupId: careGroup.id,
                                currentUserId: profile.id,
                                isClient: false
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
