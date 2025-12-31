import SwiftUI

struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var systemColorScheme
    @StateObject private var viewModel = SettingsViewModel()

    @AppStorage(UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @AppStorage(UserDefaultsKeys.notificationHour) private var notificationHour = AppConstants.defaultNotificationHour
    @AppStorage(UserDefaultsKeys.notificationMinute) private var notificationMinute = AppConstants.defaultNotificationMinute
    @AppStorage(UserDefaultsKeys.middayReminderEnabled) private var middayReminderEnabled = AppConstants.defaultMiddayReminderEnabled
    @AppStorage(UserDefaultsKeys.eveningReminderEnabled) private var eveningReminderEnabled = AppConstants.defaultEveningReminderEnabled
    @AppStorage(UserDefaultsKeys.appearanceMode) private var appearanceMode = AppearanceMode.system.rawValue

    var body: some View {
        sheetContent
            .preferredColorScheme(effectiveColorScheme)
    }

    private var effectiveColorScheme: ColorScheme {
        AppAppearance.colorScheme(for: appearanceMode) ?? systemColorScheme
    }

    private var sheetContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                settingsSection(title: "Appearance") {
                    Picker("Appearance", selection: $appearanceMode) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Text(mode.label).tag(mode.rawValue)
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
                        .onChange(of: middayReminderEnabled) { _, _ in
                            scheduleNotifications()
                        }

                    Toggle("Evening reflection", isOn: $eveningReminderEnabled)
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
                    }

#if DEBUG
                    Button("Send Test Notification") {
                        viewModel.scheduleTest()
                    }
                    .buttonStyle(PrimaryButtonStyle())
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
        viewModel.requestAndSchedule(store: TenXStore(context: modelContext),
                                     todayKey: DayKey.make(),
                                     hour: notificationHour,
                                     minute: notificationMinute,
                                     middayEnabled: middayReminderEnabled,
                                     eveningEnabled: eveningReminderEnabled)
    }

    private var weeklyReminderText: String {
        let weekdaySymbols = Calendar.current.weekdaySymbols
        let weekdayIndex = max(0, min(AppConstants.weeklyReminderWeekday - 1, weekdaySymbols.count - 1))
        let weekday = weekdaySymbols.isEmpty ? "Sunday" : weekdaySymbols[weekdayIndex]
        var components = DateComponents()
        components.hour = AppConstants.weeklyReminderHour
        components.minute = AppConstants.weeklyReminderMinute
        let date = Calendar.current.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let time = formatter.string(from: date)
        return "Weekly review reminder: \(weekday)s at \(time)"
    }
}
