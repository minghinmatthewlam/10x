import SwiftUI

struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var theme: ThemeController
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SettingsViewModel()

    @AppStorage(UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(UserDefaultsKeys.notificationHour) private var notificationHour = AppConstants.defaultNotificationHour
    @AppStorage(UserDefaultsKeys.notificationMinute) private var notificationMinute = AppConstants.defaultNotificationMinute
    @AppStorage(UserDefaultsKeys.middayReminderEnabled) private var middayReminderEnabled = AppConstants.defaultMiddayReminderEnabled
    @AppStorage(UserDefaultsKeys.eveningReminderEnabled) private var eveningReminderEnabled = AppConstants.defaultEveningReminderEnabled
    var body: some View {
        sheetContent
    }

    private var sheetContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                settingsSection(title: "Appearance") {
                    Picker("Appearance", selection: Binding(get: {
                        theme.appearanceMode
                    }, set: { mode in
                        theme.setAppearanceMode(mode)
                    })) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                settingsSection(title: "Notifications") {
                    NotificationTimePickerView(hour: $notificationHour, minute: $notificationMinute)
                        .onChange(of: notificationHour) { _, _ in
                            scheduleNotifications()
                        }
                        .onChange(of: notificationMinute) { _, _ in
                            scheduleNotifications()
                        }

                    Toggle("Midday check-in", isOn: $middayReminderEnabled)
                        .font(.tenxBody)
                        .accessibilityHint(middayReminderEnabled ? "Disables the midday check-in reminder" : "Enables a midday reminder to check your focus progress")
                        .onChange(of: middayReminderEnabled) { _, _ in
                            scheduleNotifications()
                        }

                    Toggle("Evening reflection", isOn: $eveningReminderEnabled)
                        .font(.tenxBody)
                        .accessibilityHint(eveningReminderEnabled ? "Disables the evening reflection reminder" : "Enables an evening reminder to reflect on your day")
                        .onChange(of: eveningReminderEnabled) { _, _ in
                            scheduleNotifications()
                        }

                    Text(weeklyReminderText)
                        .font(.tenxCaption)
                        .foregroundStyle(AppColors.textSecondary)

                    if viewModel.authorizationStatus == .denied {
                        Text("Notifications are disabled. Enable them in Settings.")
                            .font(.tenxCaption)
                            .foregroundStyle(AppColors.textSecondary)

                        Button("Open Settings") {
                            NotificationScheduler.shared.openSystemSettings()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .accessibilityHint("Opens the system notification settings for this app")
                    }

#if DEBUG
                    Button("Send Test Notification") {
                        viewModel.scheduleTest()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityHint("Sends a test notification to verify delivery")
#endif
                }

#if DEBUG
                settingsSection(title: "Debug") {
                    Button("Reset Onboarding") {
                        hasCompletedOnboarding = false
                        appState.showDailySetup = false
                        appState.showSettingsSheet = false
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .accessibilityHint("Returns to the onboarding carousel immediately")

                    Text("Returns to the onboarding carousel immediately.")
                        .font(.tenxCaption)
                        .foregroundStyle(AppColors.textSecondary)
                }
#endif
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(AppColors.background)
        .onAppear {
            viewModel.refreshStatus()
        }
#if DEBUG
        .alert("Test Notification", isPresented: Binding(get: {
            viewModel.testNotificationMessage != nil
        }, set: { isPresented in
            if !isPresented { viewModel.testNotificationMessage = nil }
        })) {
            Button("OK") { viewModel.testNotificationMessage = nil }
        } message: {
            Text(viewModel.testNotificationMessage ?? "")
        }
#endif
    }

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.tenxTitle)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.tenxTinyBold)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(AppColors.surface)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")
            .accessibilityHint("Dismisses the settings screen")
        }
    }

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.tenxCaption)
                .foregroundStyle(AppColors.textSecondary)
                .textCase(.uppercase)

            VStack(alignment: .leading, spacing: 16, content: content)
                .padding(16)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private func scheduleNotifications() {
        viewModel.requestAndSchedule(store: TenXStore(context: modelContext))
    }

    private var weeklyReminderText: String {
        NotificationCopy.weeklyReminderText()
    }
}
