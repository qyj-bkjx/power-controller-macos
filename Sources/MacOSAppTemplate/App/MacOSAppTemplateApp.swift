import SwiftUI

@main
struct MacOSAppTemplateApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup(appModel.dashboardViewModel.copy.appName) {
            RootSplitView()
                .environment(appModel)
                .frame(minWidth: 960, minHeight: 620)
        }
        .windowResizability(.contentMinSize)

        MenuBarExtra(appModel.dashboardViewModel.copy.appName, systemImage: appModel.dashboardViewModel.menuBarSystemImage) {
            MenuBarControlsView(viewModel: appModel.dashboardViewModel)
                .frame(width: 340)
                .padding(16)
        }

        Settings {
            SettingsView()
                .environment(appModel)
                .frame(width: 420)
                .padding(24)
        }
    }
}
