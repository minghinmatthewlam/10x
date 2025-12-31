import SwiftUI
import UserNotifications
import TenXShared

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeController

    @AppStorage(UserDefaultsKeys.notificationHour) private var notificationHour = AppConstants.defaultNotificationHour
    @AppStorage(UserDefaultsKeys.notificationMinute) private var notificationMinute = AppConstants.defaultNotificationMinute
    @AppStorage(UserDefaultsKeys.middayReminderEnabled) private var middayReminderEnabled = AppConstants.defaultMiddayReminderEnabled
    @AppStorage(UserDefaultsKeys.eveningReminderEnabled) private var eveningReminderEnabled = AppConstants.defaultEveningReminderEnabled

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
                    .listRowBackground(AppColors.surface)

                if viewModel.authorizationStatus == .denied {
                    Text("Notifications are disabled. Enable them in Settings.")
                        .foregroundStyle(AppColors.textSecondary)
                        .listRowBackground(AppColors.surface)
                    Button("Open Settings") {
                        NotificationScheduler.shared.openSystemSettings()
                    }
                    .font(.tenxBody.weight(.medium))
                    .listRowBackground(AppColors.surface)
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
                    .listRowBackground(AppColors.surface)

                Toggle("Evening reflection", isOn: $eveningReminderEnabled)
                    .onChange(of: eveningReminderEnabled) { _, _ in
                        viewModel.requestAndSchedule(store: TenXStore(context: modelContext),
                                                     todayKey: DayKey.make(),
                                                     hour: notificationHour,
                                                     minute: notificationMinute,
                                                     middayEnabled: middayReminderEnabled,
                                                     eveningEnabled: eveningReminderEnabled)
                    }
                    .listRowBackground(AppColors.surface)

                Text(weeklyReminderText)
                    .foregroundStyle(AppColors.textSecondary)
                    .listRowBackground(AppColors.surface)

                #if DEBUG
                Button("Send Test Notification") {
                    viewModel.scheduleTest()
                }
                .font(.tenxBody.weight(.medium))
                .listRowBackground(AppColors.surface)
                #endif
            } header: {
                Text("Notifications")
                    .foregroundStyle(AppColors.textSecondary)
            }

            Section {
                Picker("Mode", selection: Binding(get: {
                    theme.appearanceMode
                }, set: { mode in
                    theme.setAppearanceMode(mode)
                })) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(AppColors.surface)
            } header: {
                Text("Appearance")
                    .foregroundStyle(AppColors.textSecondary)
            }

#if DEBUG
            Section {
                NavigationLink("Diagnostics") {
                    DiagnosticsView()
                }
                .listRowBackground(AppColors.surface)
            } header: {
                Text("Debug")
                    .foregroundStyle(AppColors.textSecondary)
            }
#endif
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .tint(AppColors.accent)
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
