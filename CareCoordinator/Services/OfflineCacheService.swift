// CareCoordinator/Services/OfflineCacheService.swift
import Foundation
import Network
import SwiftData

@Observable
final class OfflineCacheService {
    var isOnline = true

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.carecoordinator.network-monitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                if path.status == .satisfied {
                    Task { await self?.syncPendingActions() }
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }

    // MARK: - Cache Shifts

    func cacheShifts(_ shifts: [Shift], context: ModelContext) {
        for shift in shifts {
            let cached = CachedShift(from: shift)
            context.insert(cached)
        }
        try? context.save()
    }

    func loadCachedShifts(careGroupId: UUID, context: ModelContext) -> [Shift] {
        let predicate = #Predicate<CachedShift> { $0.careGroupId == careGroupId }
        let descriptor = FetchDescriptor<CachedShift>(predicate: predicate)
        let cached = (try? context.fetch(descriptor)) ?? []
        return cached.map { $0.toShift() }
    }

    // MARK: - Cache Tasks

    func cacheTasks(_ tasks: [CareTask], context: ModelContext) {
        for task in tasks {
            let cached = CachedTask(from: task)
            context.insert(cached)
        }
        try? context.save()
    }

    // MARK: - Pending Sync Queue

    func queueAction(
        entityType: String,
        entityId: UUID,
        action: String,
        payload: some Encodable,
        context: ModelContext
    ) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        let pending = PendingSyncAction(
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: data
        )
        context.insert(pending)
        try? context.save()
    }

    func syncPendingActions() async {
        // Process the PendingSyncAction queue when the device comes back online.
        // Each action is replayed against the appropriate repository.
        // Implementation depends on ModelContainer access pattern provided by the app.
    }

    // MARK: - Clear Cache (on logout)

    func clearCache(context: ModelContext) {
        try? context.delete(model: CachedShift.self)
        try? context.delete(model: CachedTask.self)
        try? context.delete(model: PendingSyncAction.self)
        try? context.save()
    }
}
