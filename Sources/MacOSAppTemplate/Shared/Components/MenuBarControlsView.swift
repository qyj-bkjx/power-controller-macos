import SwiftUI

struct MenuBarControlsView: View {
    @Bindable var viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(viewModel.copy.appName)
                .font(.headline)

            Toggle(
                viewModel.copy.lidControlTitle,
                isOn: Binding(
                    get: { viewModel.lidSleepDisabled },
                    set: { newValue in
                        Task {
                            await viewModel.setLidSleepDisabled(newValue)
                        }
                    }
                )
            )
            .disabled(viewModel.isUpdatingLidSleep)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(viewModel.copy.autoSleepLabel)
                    Spacer()
                    Text("\(Int(viewModel.autoSleepMinutes)) \(viewModel.copy.minutesUnit)")
                        .monospacedDigit()
                }

                Slider(value: $viewModel.autoSleepMinutes, in: 1...240, step: 1)
            }

            HStack {
                Button(viewModel.copy.startTimerButton) {
                    viewModel.scheduleSleep()
                }
                .buttonStyle(.borderedProminent)

                Button(viewModel.copy.cancelTimerButton) {
                    viewModel.cancelScheduledSleep()
                }
                .buttonStyle(.bordered)
            }

            Divider()

            Text(viewModel.menuBarSummary)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .task {
            await viewModel.refreshPowerStatus()
        }
    }
}
