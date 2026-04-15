import SwiftUI

struct SettingsView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        Form {
            Text(appModel.dashboardViewModel.copy.settingsReady)
                .font(.headline)

            Picker(
                appModel.dashboardViewModel.copy.languageLabel,
                selection: Binding(
                    get: { appModel.language },
                    set: { appModel.language = $0 }
                )
            ) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.settingsLabel).tag(language)
                }
            }

            LabeledContent(
                appModel.dashboardViewModel.copy.currentSectionLabel,
                value: appModel.selectedSection.title(for: appModel.language)
            )
            LabeledContent(appModel.dashboardViewModel.copy.architectureLabel, value: "SwiftUI + MVVM + Services")
            LabeledContent(appModel.dashboardViewModel.copy.targetLabel, value: "macOS 14+")
            LabeledContent(appModel.dashboardViewModel.copy.powerCommandLabel, value: "pmset")
            LabeledContent(appModel.dashboardViewModel.copy.menuBarLabel, value: appModel.dashboardViewModel.copy.menuBarEnabledValue)
            LabeledContent(appModel.dashboardViewModel.copy.reminderLabel, value: appModel.dashboardViewModel.copy.reminderValue)
        }
        .formStyle(.grouped)
        .navigationTitle(appModel.dashboardViewModel.copy.settingsSectionTitle)
    }
}
