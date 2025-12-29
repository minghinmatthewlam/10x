import SwiftUI
import UserNotifications
import TenXShared

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.modelContext) private var modelContext

    @AppStorage(UserDefaultsKeys.notificationHour) private var notificationHour = AppConstants.defaultNotificationHour
    @AppStorage(UserDefaultsKeys.notificationMinute) private var notificationMinute = AppConstants.defaultNotificationMinute
    @AppStorage(UserDefaultsKeys.middayReminderEnabled) private var middayReminderEnabled = AppConstants.defaultMiddayReminderEnabled
    @AppStorage(UserDefaultsKeys.eveningReminderEnabled) private var eveningReminderEnabled = AppConstants.defaultEveningReminderEnabled
    @AppStorage(UserDefaultsKeys.appearanceMode) private var appearanceMode = AppearanceMode.system.rawValue
    @Environment(\.tenxTheme) private var theme

    var body: some View {
        Form {
            Section("Notifications") {
                NotificationTimePickerView(hour: $notificationHour, minute: $notificationMinute)
                    .onChange(of: notificationHour) { _, _ in
                        viewModel.requestAndSchedule(store: TenXStore(context: modelContext),
                                                     todayKey: DayKey.make(),
                                                     hour: notificationHour,
                                                     minute: notificationMinute,
                                                     middayEnabled: middayReminderEnabled,
                                                     eveningEnabled: eveningReminderEnabled)
                    }
                    .onChange(of: notificationMinute) { _, _ in
                        viewModel.requestAndSchedule(store: TenXStore(context: modelContext),
                                                     todayKey: DayKey.make(),
                                                     hour: notificationHour,
                                                     minute: notificationMinute,
                                                     middayEnabled: middayReminderEnabled,
                                                     eveningEnabled: eveningReminderEnabled)
                    }

                Text(statusText)
                    .foregroundStyle(theme.textSecondary)

                if viewModel.authorizationStatus == .denied {
                    Button("Open Settings") {
                        NotificationScheduler.shared.openSystemSettings()
                    }
                }

                Toggle("Midday check-in", isOn: $middayReminderEnabled)
                    .onChange(of: middayReminderEnabled) { _, _ in
                        viewModel.requestAndSchedule(store: TenXStore(context: modelContext),
                                                     todayKey: DayKey.make(),
                                                     hour: notificationHour,
                                                     minute: notificationMinute,
                                                     middayEnabled: middayReminderEnabled,
                                                     eveningEnabled: eveningReminderEnabled)
                    }

                Toggle("Evening reflection", isOn: $eveningReminderEnabled)
                    .onChange(of: eveningReminderEnabled) { _, _ in
                        viewModel.requestAndSchedule(store: TenXStore(context: modelContext),
                                                     todayKey: DayKey.make(),
                                                     hour: notificationHour,
                                                     minute: notificationMinute,
                                                     middayEnabled: middayReminderEnabled,
                                                     eveningEnabled: eveningReminderEnabled)
                    }

                #if DEBUG
                Button("Send Test Notification") {
                    viewModel.scheduleTest()
                }
                #endif
            }

            Section("Theme") {
                Picker("Style", selection: $themeManager.theme) {
                    ForEach(Theme.allCases) { theme in
                        Text(theme.label).tag(theme)
                    }
                }
                .pickerStyle(.navigationLink)
            }

            Section("Appearance") {
                Picker("Mode", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Settings")
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

    private var statusText: String {
        switch viewModel.authorizationStatus {
        case .authorized, .provisional:
            return "Reminders enabled"
        case .denied:
            return "Reminders denied"
        case .notDetermined:
            return "Reminders not set"
        case .ephemeral:
            return "Reminders temporary"
        @unknown default:
            return "Reminders status unknown"
        }
    }
}
