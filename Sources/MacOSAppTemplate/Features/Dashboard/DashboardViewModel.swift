import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private let services: AppServices
    private var scheduledSleepTask: Task<Void, Never>?
    private var preSleepNotificationTask: Task<Void, Never>?

    var language: AppLanguage {
        didSet {
            refreshLocalizedContent()
        }
    }
    private(set) var lastCopiedTimestamp = ""
    var lidSleepDisabled = false
    var isUpdatingLidSleep = false
    var autoSleepMinutes = 30.0
    var scheduledSleepDescription: String
    var statusMessage: String
    var errorMessage: String?
    var sleepDeadline: Date?

    init(services: AppServices, language: AppLanguage) {
        self.services = services
        self.language = language
        self.scheduledSleepDescription = Self.idleScheduledSleepDescription(for: language)
        self.statusMessage = Self.readyStatusMessage(for: language)
        self.lastCopiedTimestamp = services.clock.nowText()
    }

    var copy: LocalizedCopy {
        LocalizedCopy.make(for: language)
    }

    var headline: String { copy.headline }
    var checklist: [String] { copy.capabilities }

    var menuBarSummary: String {
        if let errorMessage {
            return errorMessage
        }

        return scheduledSleepDescription
    }

    var menuBarSystemImage: String {
        if sleepDeadline != nil {
            return "moon.zzz.fill"
        }

        return lidSleepDisabled ? "powerplug.fill" : "powerplug"
    }

    func copyStatus() {
        let text = """
        \(localizedToggleLine())
        \(localizedAutoSleepLine())
        \(localizedUpdatedAtLine())
        """
        services.clipboard.copy(text)
        lastCopiedTimestamp = services.clock.nowText()
    }

    func refreshPowerStatus() async {
        do {
            lidSleepDisabled = try await services.power.lidSleepDisabled()
            statusMessage = lidSleepDisabled
                ? localizedLidSleepDisabledStatus()
                : localizedSystemDefaultStatus()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setLidSleepDisabled(_ disabled: Bool) async {
        isUpdatingLidSleep = true
        defer { isUpdatingLidSleep = false }

        do {
            try await services.power.setLidSleepDisabled(disabled)
            lidSleepDisabled = disabled
            statusMessage = disabled
                ? localizedLidSleepChangedStatus(enabled: true)
                : localizedLidSleepChangedStatus(enabled: false)
            errorMessage = nil
        } catch {
            lidSleepDisabled.toggle()
            errorMessage = error.localizedDescription
        }
    }

    func scheduleSleep() {
        cancelScheduledSleep()

        let minutes = max(autoSleepMinutes, 1)
        autoSleepMinutes = minutes
        let deadline = Date().addingTimeInterval(minutes * 60)
        sleepDeadline = deadline
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none

        scheduledSleepDescription = localizedScheduledSleepDescription(timeText: formatter.string(from: deadline))
        statusMessage = localizedAutoSleepStartedStatus()
        errorMessage = nil
        let notificationTitle = localizedNotificationTitle()
        let notificationBody = localizedNotificationBody()
        let sleepSentDescription = localizedSleepSentDescription()
        let autoSleepCompletedStatus = localizedAutoSleepCompletedStatus()
        let sleepFailedDescription = localizedSleepFailedDescription()

        if minutes > 1 {
            preSleepNotificationTask = Task { [services] in
                do {
                    try await services.sleepScheduler.sleep(for: .seconds((minutes - 1) * 60))
                    try await services.notifications.requestAuthorizationIfNeeded()
                    try await services.notifications.send(
                        title: notificationTitle,
                        body: notificationBody
                    )
                } catch is CancellationError {
                    return
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }

        scheduledSleepTask = Task { [services] in
            do {
                try await services.sleepScheduler.sleep(for: .seconds(minutes * 60))
                try await services.power.sleepNow()
                await MainActor.run {
                    self.sleepDeadline = nil
                    self.scheduledSleepDescription = sleepSentDescription
                    self.statusMessage = autoSleepCompletedStatus
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.sleepDeadline = nil
                    self.scheduledSleepDescription = sleepFailedDescription
                }
            }
        }
    }

    func cancelScheduledSleep() {
        scheduledSleepTask?.cancel()
        preSleepNotificationTask?.cancel()
        scheduledSleepTask = nil
        preSleepNotificationTask = nil
        sleepDeadline = nil
        scheduledSleepDescription = Self.idleScheduledSleepDescription(for: language)
        statusMessage = localizedAutoSleepCancelledStatus()
    }

    private func refreshLocalizedContent() {
        if let sleepDeadline {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            scheduledSleepDescription = localizedScheduledSleepDescription(timeText: formatter.string(from: sleepDeadline))
        } else if scheduledSleepDescription == localizedSleepSentDescription() || scheduledSleepDescription == localizedSleepFailedDescription() {
            scheduledSleepDescription = scheduledSleepDescription == localizedSleepSentDescription()
                ? localizedSleepSentDescription()
                : localizedSleepFailedDescription()
        } else {
            scheduledSleepDescription = Self.idleScheduledSleepDescription(for: language)
        }

        if errorMessage == nil {
            statusMessage = lidSleepDisabled
                ? localizedLidSleepDisabledStatus()
                : Self.readyStatusMessage(for: language)
        }
    }

    private static func idleScheduledSleepDescription(for language: AppLanguage) -> String {
        switch language {
        case .english:
            "No sleep timer is running."
        case .simplifiedChinese:
            "当前没有运行中的睡眠计时。"
        }
    }

    private static func readyStatusMessage(for language: AppLanguage) -> String {
        switch language {
        case .english:
            "Power controls are ready."
        case .simplifiedChinese:
            "电源控制已准备就绪。"
        }
    }

    private func localizedToggleLine() -> String {
        switch language {
        case .simplifiedChinese:
            "合盖保持唤醒：\(lidSleepDisabled ? \"已开启\" : \"已关闭\")"
        case .english:
            "Lid closed stay awake: \(lidSleepDisabled ? \"On\" : \"Off\")"
        }
    }

    private func localizedAutoSleepLine() -> String {
        switch language {
        case .simplifiedChinese:
            "自动睡眠：\(scheduledSleepDescription)"
        case .english:
            "Auto sleep: \(scheduledSleepDescription)"
        }
    }

    private func localizedUpdatedAtLine() -> String {
        switch language {
        case .simplifiedChinese:
            "更新时间：\(services.clock.nowText())"
        case .english:
            "Updated: \(services.clock.nowText())"
        }
    }

    private func localizedLidSleepDisabledStatus() -> String {
        switch language {
        case .simplifiedChinese:
            "当前已关闭合盖睡眠。"
        case .english:
            "Lid-close sleep is currently disabled."
        }
    }

    private func localizedSystemDefaultStatus() -> String {
        switch language {
        case .simplifiedChinese:
            "当前正在使用系统默认的合盖睡眠策略。"
        case .english:
            "Lid-close sleep is currently using the system default."
        }
    }

    private func localizedLidSleepChangedStatus(enabled: Bool) -> String {
        switch (language, enabled) {
        case (.simplifiedChinese, true):
            "已关闭合盖睡眠。"
        case (.simplifiedChinese, false):
            "已恢复系统默认的合盖睡眠策略。"
        case (.english, true):
            "Lid-close sleep has been disabled."
        case (.english, false):
            "Lid-close sleep has been restored to the system default."
        }
    }

    private func localizedScheduledSleepDescription(timeText: String) -> String {
        switch language {
        case .simplifiedChinese:
            "已安排在 \(timeText) 进入睡眠。"
        case .english:
            "Sleep scheduled for \(timeText)."
        }
    }

    private func localizedAutoSleepStartedStatus() -> String {
        switch language {
        case .simplifiedChinese:
            "自动睡眠计时已启动。"
        case .english:
            "Auto-sleep is armed."
        }
    }

    private func localizedNotificationTitle() -> String {
        switch language {
        case .simplifiedChinese:
            "Mac 即将睡眠"
        case .english:
            "Mac sleeping soon"
        }
    }

    private func localizedNotificationBody() -> String {
        switch language {
        case .simplifiedChinese:
            "你的 Mac 将在 1 分钟后进入睡眠。"
        case .english:
            "Your Mac is scheduled to sleep in 1 minute."
        }
    }

    private func localizedSleepSentDescription() -> String {
        switch language {
        case .simplifiedChinese:
            "已发送睡眠指令。"
        case .english:
            "Sleep command sent."
        }
    }

    private func localizedAutoSleepCompletedStatus() -> String {
        switch language {
        case .simplifiedChinese:
            "自动睡眠已完成。"
        case .english:
            "Auto-sleep completed."
        }
    }

    private func localizedSleepFailedDescription() -> String {
        switch language {
        case .simplifiedChinese:
            "睡眠计时执行失败。"
        case .english:
            "Sleep timer failed."
        }
    }

    private func localizedAutoSleepCancelledStatus() -> String {
        switch language {
        case .simplifiedChinese:
            "已取消自动睡眠计时。"
        case .english:
            "Auto-sleep was canceled."
        }
    }
}
