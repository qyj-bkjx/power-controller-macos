import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case simplifiedChinese = "zh-Hans"
    case english = "en"

    var id: String { rawValue }

    var settingsLabel: String {
        switch self {
        case .simplifiedChinese:
            "简体中文"
        case .english:
            "English"
        }
    }
}

struct LocalizedCopy {
    let appName: String
    let powerSectionTitle: String
    let settingsSectionTitle: String
    let dashboardTitle: String
    let headline: String
    let capabilitiesTitle: String
    let capabilities: [String]
    let lidControlTitle: String
    let lidControlToggle: String
    let lidControlHelp: String
    let autoSleepTitle: String
    let autoSleepLabel: String
    let minutesUnit: String
    let startTimerButton: String
    let cancelTimerButton: String
    let targetSleepTimePrefix: String
    let copyStatusButton: String
    let lastCopiedPrefix: String
    let settingsReady: String
    let currentSectionLabel: String
    let languageLabel: String
    let architectureLabel: String
    let targetLabel: String
    let powerCommandLabel: String
    let menuBarLabel: String
    let reminderLabel: String
    let menuBarEnabledValue: String
    let reminderValue: String

    static func make(for language: AppLanguage) -> LocalizedCopy {
        switch language {
        case .simplifiedChinese:
            LocalizedCopy(
                appName: "电源控制",
                powerSectionTitle: "电源",
                settingsSectionTitle: "设置",
                dashboardTitle: "电源控制",
                headline: "让 Mac 在合盖时继续工作，并按你的计划自动进入睡眠。",
                capabilitiesTitle: "功能说明",
                capabilities: [
                    "需要持续运行任务时，可以开启合盖保持唤醒",
                    "可以设置倒计时，到点后自动让系统进入睡眠",
                    "睡眠前 1 分钟会发送本地通知提醒",
                    "只有修改系统电源策略时才会请求管理员授权"
                ],
                lidControlTitle: "合盖保持唤醒",
                lidControlToggle: "关闭盒盖时不进入睡眠",
                lidControlHelp: "这里会调用 `pmset disablesleep`，切换时 macOS 可能要求管理员授权。",
                autoSleepTitle: "定时自动睡眠",
                autoSleepLabel: "多久后睡眠",
                minutesUnit: "分钟",
                startTimerButton: "开始计时",
                cancelTimerButton: "取消计时",
                targetSleepTimePrefix: "预计睡眠时间：",
                copyStatusButton: "复制状态",
                lastCopiedPrefix: "最近复制：",
                settingsReady: "电源控制工具已就绪。",
                currentSectionLabel: "当前页面",
                languageLabel: "界面语言",
                architectureLabel: "架构",
                targetLabel: "系统要求",
                powerCommandLabel: "电源命令",
                menuBarLabel: "菜单栏",
                reminderLabel: "提醒时间",
                menuBarEnabledValue: "已启用",
                reminderValue: "睡眠前 1 分钟"
            )
        case .english:
            LocalizedCopy(
                appName: "Power Controller",
                powerSectionTitle: "Power",
                settingsSectionTitle: "Settings",
                dashboardTitle: "Power Controller",
                headline: "Keep your Mac awake with the lid closed, then let it sleep on your schedule.",
                capabilitiesTitle: "Capabilities",
                capabilities: [
                    "Keep your Mac awake with the lid closed while work continues",
                    "Start a countdown to put the Mac to sleep automatically",
                    "Get a local reminder 1 minute before sleep",
                    "Only request admin approval when a system power setting changes"
                ],
                lidControlTitle: "Lid Closed Stay Awake",
                lidControlToggle: "Do not sleep when the lid is closed",
                lidControlHelp: "This uses `pmset disablesleep`, and macOS may ask for administrator approval when you change it.",
                autoSleepTitle: "Auto Sleep Timer",
                autoSleepLabel: "Sleep after",
                minutesUnit: "min",
                startTimerButton: "Start Timer",
                cancelTimerButton: "Cancel Timer",
                targetSleepTimePrefix: "Target sleep time: ",
                copyStatusButton: "Copy Status",
                lastCopiedPrefix: "Last copied: ",
                settingsReady: "Power Controller is ready.",
                currentSectionLabel: "Current section",
                languageLabel: "App language",
                architectureLabel: "Architecture",
                targetLabel: "Target",
                powerCommandLabel: "Power command",
                menuBarLabel: "Menu bar",
                reminderLabel: "Reminder",
                menuBarEnabledValue: "Enabled",
                reminderValue: "1 minute before sleep"
            )
        }
    }
}
