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
            Section {
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
                    .listRowBackground(theme.surface)

                if viewModel.authorizationStatus == .denied {
                    Text("Notifications are disabled. Enable them in Settings.")
                        .foregroundStyle(theme.textSecondary)
                        .listRowBackground(theme.surface)
                    Button("Open Settings") {
                        NotificationScheduler.shared.openSystemSettings()
                    }
                    .listRowBackground(theme.surface)
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
                    .listRowBackground(theme.surface)

                Toggle("Evening reflection", isOn: $eveningReminderEnabled)
                    .onChange(of: eveningReminderEnabled) { _, _ in
                        viewModel.requestAndSchedule(store: TenXStore(context: modelContext),
                                                     todayKey: DayKey.make(),
                                                     hour: notificationHour,
                                                     minute: notificationMinute,
                                                     middayEnabled: middayReminderEnabled,
                                                     eveningEnabled: eveningReminderEnabled)
                    }
                    .listRowBackground(theme.surface)

                Text(weeklyReminderText)
                    .foregroundStyle(theme.textSecondary)
                    .listRowBackground(theme.surface)

                #if DEBUG
                Button("Send Test Notification") {
                    viewModel.scheduleTest()
                }
                .listRowBackground(theme.surface)
                #endif
            } header: {
                Text("Notifications")
                    .foregroundStyle(theme.textSecondary)
            }

            Section {
                NavigationLink("Style") {
                    ThemePickerView()
                }
                .listRowBackground(theme.surface)
            } header: {
                Text("Theme")
                    .foregroundStyle(theme.textSecondary)
            }

            Section {
                Picker("Mode", selection: $appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(theme.surface)
            } header: {
                Text("Appearance")
                    .foregroundStyle(theme.textSecondary)
            }

#if DEBUG
            Section {
                NavigationLink("Diagnostics") {
                    DiagnosticsView()
                }
                .listRowBackground(theme.surface)
            } header: {
                Text("Debug")
                    .foregroundStyle(theme.textSecondary)
            }
#endif
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(theme.background)
        .toolbarBackground(theme.background, for: .navigationBar)
        .tint(theme.accent)
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
