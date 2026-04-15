import Foundation
import UserNotifications

protocol NotificationServicing: Sendable {
    func requestAuthorizationIfNeeded() async throws
    func send(title: String, body: String) async throws
}

struct UserNotificationService: NotificationServicing {
    func requestAuthorizationIfNeeded() async throws {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return
        case .denied:
            return
        case .notDetermined:
            _ = try await center.requestAuthorization(options: [.alert, .sound])
        @unknown default:
            return
        }
    }

    func send(title: String, body: String) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        try await UNUserNotificationCenter.current().add(request)
    }
}
