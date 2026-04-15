import SwiftUI

struct RootSplitView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, selection: selectionBinding) { item in
                Label(item.title(for: appModel.language), systemImage: item.systemImage)
                    .tag(item)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            Group {
                switch appModel.selectedSection {
                case .dashboard:
                    DashboardView(viewModel: appModel.dashboardViewModel)
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    private var selectionBinding: Binding<SidebarItem?> {
        Binding(
            get: { appModel.selectedSection },
            set: { appModel.selectedSection = $0 ?? .dashboard }
        )
    }
}
