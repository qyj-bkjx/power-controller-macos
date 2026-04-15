import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    var selectedSection: SidebarItem = .dashboard
    var services: AppServices
    var dashboardViewModel: DashboardViewModel
    var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app.language")
            dashboardViewModel.language = language
        }
    }

    init(services: AppServices = .live) {
        let savedLanguage = UserDefaults.standard.string(forKey: "app.language")
        let language = AppLanguage(rawValue: savedLanguage ?? "") ?? .simplifiedChinese

        self.services = services
        self.language = language
        self.dashboardViewModel = DashboardViewModel(services: services, language: language)
    }
}
