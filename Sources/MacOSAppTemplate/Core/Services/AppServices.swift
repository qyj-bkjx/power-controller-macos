import Foundation

struct AppServices: Sendable {
    var clipboard: any ClipboardServicing
    var clock: any ClockServicing
    var power: any PowerManagementServicing
    var sleepScheduler: any SleepScheduling
    var notifications: any NotificationServicing

    init(
        clipboard: any ClipboardServicing = ClipboardService(),
        clock: any ClockServicing = SystemClockService(),
        power: any PowerManagementServicing = PowerManagementService(),
        sleepScheduler: any SleepScheduling = TaskSleepScheduler(),
        notifications: any NotificationServicing = UserNotificationService()
    ) {
        self.clipboard = clipboard
        self.clock = clock
        self.power = power
        self.sleepScheduler = sleepScheduler
        self.notifications = notifications
    }

    static let live = AppServices()
}
