import Foundation

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard
    case settings

    var id: String { rawValue }

    func title(for language: AppLanguage) -> String {
        let copy = LocalizedCopy.make(for: language)

        return switch self {
        case .dashboard:
            copy.powerSectionTitle
        case .settings:
            copy.settingsSectionTitle
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard:
            "powerplug"
        case .settings:
            "gearshape"
        }
    }
}
