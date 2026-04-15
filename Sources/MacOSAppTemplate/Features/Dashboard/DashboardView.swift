import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.copy.dashboardTitle)
                        .font(.largeTitle)
                        .fontWeight(.semibold)

                    Text(viewModel.headline)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.copy.capabilitiesTitle)
                        .font(.headline)

                    ForEach(viewModel.checklist, id: \.self) { item in
                        Label(item, systemImage: "checkmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .padding(20)
                .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.copy.lidControlTitle)
                        .font(.headline)

                    Toggle(
                        viewModel.copy.lidControlToggle,
                        isOn: Binding(
                            get: { viewModel.lidSleepDisabled },
                            set: { newValue in
                                Task {
                                    await viewModel.setLidSleepDisabled(newValue)
                                }
                            }
                        )
                    )
                        .toggleStyle(.switch)
                        .disabled(viewModel.isUpdatingLidSleep)

                    Text(viewModel.copy.lidControlHelp)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 16) {
                    Text(viewModel.copy.autoSleepTitle)
                        .font(.headline)

                    HStack(alignment: .center, spacing: 12) {
                        Text(viewModel.copy.autoSleepLabel)
                        Slider(value: $viewModel.autoSleepMinutes, in: 1...240, step: 1)
                        Text("\(Int(viewModel.autoSleepMinutes)) \(viewModel.copy.minutesUnit)")
                            .monospacedDigit()
                            .frame(width: 72, alignment: .trailing)
                    }

                    HStack(spacing: 12) {
                        Button(viewModel.copy.startTimerButton) {
                            viewModel.scheduleSleep()
                        }
                        .buttonStyle(.borderedProminent)

                        Button(viewModel.copy.cancelTimerButton) {
                            viewModel.cancelScheduledSleep()
                        }
                        .buttonStyle(.bordered)
                    }

                    Text(viewModel.scheduledSleepDescription)
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.statusMessage)
                        .foregroundStyle(.primary)

                    if let sleepDeadline = viewModel.sleepDeadline {
                        Text("\(viewModel.copy.targetSleepTimePrefix)\(sleepDeadline.formatted(date: .omitted, time: .shortened))")
                            .foregroundStyle(.secondary)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                HStack(spacing: 12) {
                    Button(viewModel.copy.copyStatusButton) {
                        viewModel.copyStatus()
                    }
                    .buttonStyle(.bordered)

                    Text("\(viewModel.copy.lastCopiedPrefix)\(viewModel.lastCopiedTimestamp)")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(28)
        }
        .navigationTitle(viewModel.copy.powerSectionTitle)
        .task {
            await viewModel.refreshPowerStatus()
        }
    }
}
