// CareCoordinator/Services/RealtimeService.swift
import Foundation
import Supabase
import Realtime

@Observable
final class RealtimeService {
    private let supabase = SupabaseManager.client
    private var channels: [RealtimeChannelV2] = []

    var onShiftChange: ((Shift) -> Void)?
    var onTaskChange: ((CareTask) -> Void)?
    var onNotification: ((CareNotification) -> Void)?

    func subscribeToShifts(careGroupId: UUID) async {
        let channel = supabase.realtimeV2.channel("shifts_\(careGroupId)")

        let changes = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "shifts",
            filter: "care_group_id=eq.\(careGroupId)"
        )

        await channel.subscribe()

        Task {
            for await change in changes {
                if let shift = try? change.decodeRecord(as: Shift.self, decoder: JSONDecoder()) {
                    await MainActor.run {
                        onShiftChange?(shift)
                    }
                }
            }
        }

        channels.append(channel)
    }

    func subscribeToTasks(careGroupId: UUID) async {
        let channel = supabase.realtimeV2.channel("tasks_\(careGroupId)")

        let changes = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "tasks",
            filter: "care_group_id=eq.\(careGroupId)"
        )

        await channel.subscribe()

        Task {
            for await change in changes {
                if let task = try? change.decodeRecord(as: CareTask.self, decoder: JSONDecoder()) {
                    await MainActor.run {
                        onTaskChange?(task)
                    }
                }
            }
        }

        channels.append(channel)
    }

    func subscribeToNotifications(userId: UUID) async {
        let channel = supabase.realtimeV2.channel("notifications_\(userId)")

        let inserts = channel.postgresChange(
            InsertAction.self,
            schema: "public",
            table: "notifications",
            filter: "user_id=eq.\(userId)"
        )

        await channel.subscribe()

        Task {
            for await insert in inserts {
                if let notification = try? insert.decodeRecord(as: CareNotification.self, decoder: JSONDecoder()) {
                    await MainActor.run {
                        onNotification?(notification)
                    }
                }
            }
        }

        channels.append(channel)
    }

    func unsubscribeAll() async {
        for channel in channels {
            await channel.unsubscribe()
        }
        channels.removeAll()
    }
}
