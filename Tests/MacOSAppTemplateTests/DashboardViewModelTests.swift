import Testing
@testable import MacOSAppTemplate

struct DashboardViewModelTests {
    @Test
    @MainActor
    func copyStatusRefreshesTimestamp() {
        let clipboard = ClipboardServiceSpy()
        let clock = ClockServiceStub(values: ["Before", "During", "After"])
        let services = AppServices(
            clipboard: clipboard,
            clock: clock,
            power: PowerManagementServiceStub(),
            sleepScheduler: SleepSchedulerSpy(),
            notifications: NotificationServiceSpy()
        )
        let viewModel = DashboardViewModel(services: services, language: .simplifiedChinese)

        viewModel.copyStatus()

        #expect(viewModel.lastCopiedTimestamp == "After")
        #expect(clipboard.lastValue?.contains("合盖保持唤醒：已关闭") == true)
        #expect(clipboard.lastValue?.contains("During") == true)
    }

    @Test
    @MainActor
    func setLidSleepDisabledUpdatesStatus() async {
        let power = PowerManagementServiceStub()
        let services = AppServices(
            clipboard: ClipboardServiceSpy(),
            clock: ClockServiceStub(values: ["Now"]),
            power: power,
            sleepScheduler: SleepSchedulerSpy(),
            notifications: NotificationServiceSpy()
        )
        let viewModel = DashboardViewModel(services: services, language: .simplifiedChinese)

        await viewModel.setLidSleepDisabled(true)

        #expect(power.lastLidSleepValue == true)
        #expect(viewModel.lidSleepDisabled == true)
        #expect(viewModel.statusMessage == "已关闭合盖睡眠。")
    }

    @Test
    @MainActor
    func scheduleSleepArmsTimer() {
        let scheduler = SleepSchedulerSpy()
        let services = AppServices(
            clipboard: ClipboardServiceSpy(),
            clock: ClockServiceStub(values: ["Now"]),
            power: PowerManagementServiceStub(),
            sleepScheduler: scheduler,
            notifications: NotificationServiceSpy()
        )
        let viewModel = DashboardViewModel(services: services, language: .simplifiedChinese)

        viewModel.autoSleepMinutes = 5
        viewModel.scheduleSleep()

        #expect(viewModel.scheduledSleepDescription.contains("已安排在"))
        #expect(viewModel.statusMessage == "自动睡眠计时已启动。")
    }

    @Test
    @MainActor
    func scheduleSleepCallsSleepScheduler() async {
        let power = PowerManagementServiceStub()
        let scheduler = SleepSchedulerSpy()
        let services = AppServices(
            clipboard: ClipboardServiceSpy(),
            clock: ClockServiceStub(values: ["Now"]),
            power: power,
            sleepScheduler: scheduler,
            notifications: NotificationServiceSpy()
        )
        let viewModel = DashboardViewModel(services: services, language: .simplifiedChinese)

        viewModel.autoSleepMinutes = 5
        viewModel.scheduleSleep()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(scheduler.durations.contains(.seconds(300)))
        #expect(power.sleepNowCallCount == 1)
    }

    @Test
    @MainActor
    func scheduleSleepTriggersPreSleepNotification() async {
        let notifications = NotificationServiceSpy()
        let services = AppServices(
            clipboard: ClipboardServiceSpy(),
            clock: ClockServiceStub(values: ["Now"]),
            power: PowerManagementServiceStub(),
            sleepScheduler: SleepSchedulerSpy(),
            notifications: notifications
        )
        let viewModel = DashboardViewModel(services: services, language: .simplifiedChinese)

        viewModel.autoSleepMinutes = 2
        viewModel.scheduleSleep()
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(notifications.authorizationRequested == true)
        #expect(notifications.lastTitle == "Mac 即将睡眠")
    }

    @Test
    @MainActor
    func languageSwitchUpdatesCopy() {
        let services = AppServices(
            clipboard: ClipboardServiceSpy(),
            clock: ClockServiceStub(values: ["Now"]),
            power: PowerManagementServiceStub(),
            sleepScheduler: SleepSchedulerSpy(),
            notifications: NotificationServiceSpy()
        )
        let viewModel = DashboardViewModel(services: services, language: .simplifiedChinese)

        viewModel.language = .english

        #expect(viewModel.copy.appName == "Power Controller")
        #expect(viewModel.headline.contains("Keep your Mac awake"))
    }
}

@MainActor
private final class ClipboardServiceSpy: @unchecked Sendable, ClipboardServicing {
    var lastValue: String?

    func copy(_ value: String) {
        lastValue = value
    }
}

@MainActor
private final class ClockServiceStub: @unchecked Sendable, ClockServicing {
    private var values: [String]

    init(values: [String]) {
        self.values = values
    }

    func nowText() -> String {
        guard !values.isEmpty else { return "Fallback" }
        return values.removeFirst()
    }
}

private final class PowerManagementServiceStub: @unchecked Sendable, PowerManagementServicing {
    var currentDisabled = false
    var lastLidSleepValue: Bool?
    var sleepNowCallCount = 0

    func lidSleepDisabled() async throws -> Bool {
        currentDisabled
    }

    func setLidSleepDisabled(_ disabled: Bool) async throws {
        currentDisabled = disabled
        lastLidSleepValue = disabled
    }

    func sleepNow() async throws {
        sleepNowCallCount += 1
    }
}

private final class SleepSchedulerSpy: @unchecked Sendable, SleepScheduling {
    var durations: [Duration] = []

    func sleep(for duration: Duration) async throws {
        durations.append(duration)
    }
}

private final class NotificationServiceSpy: @unchecked Sendable, NotificationServicing {
    var authorizationRequested = false
    var lastTitle: String?
    var lastBody: String?

    func requestAuthorizationIfNeeded() async throws {
        authorizationRequested = true
    }

    func send(title: String, body: String) async throws {
        lastTitle = title
        lastBody = body
    }
}
