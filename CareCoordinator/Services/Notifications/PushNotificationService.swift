// CareCoordinator/Services/Notifications/PushNotificationService.swift
import Foundation
import UserNotifications
import UIKit

final class PushNotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PushNotificationService()

    private override init() {
        super.init()
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            return false
        }
    }

    func saveDeviceToken(_ deviceToken: Data) async {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()

        // Store token in Supabase for server-side push (via Edge Function or direct)
        do {
            let userId = try await SupabaseManager.client.auth.session.user.id
            try await SupabaseManager.client
                .from("profiles")
                .update(["device_token": token])
                .eq("id", value: userId)
                .execute()
        } catch {
            print("Failed to save device token: \(error)")
        }
    }

    // Handle foreground notifications
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        // Handle deep linking based on notification type
        if let type = userInfo["type"] as? String {
            NotificationCenter.default.post(
                name: .didTapPushNotification,
                object: nil,
                userInfo: ["type": type, "data": userInfo]
            )
        }
    }
}

extension Notification.Name {
    static let didTapPushNotification = Notification.Name("didTapPushNotification")
}
