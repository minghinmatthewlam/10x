import SwiftUI
import UserNotifications

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    @AppStorage(UserDefaultsKeys.notificationHour) private var notificationHour = AppConstants.defaultNotificationHour
    @AppStorage(UserDefaultsKeys.notificationMinute) private var notificationMinute = AppConstants.defaultNotificationMinute
    @AppStorage(UserDefaultsKeys.appearanceMode) private var appearanceMode = AppearanceMode.system.rawValue

    var body: some View {
        Form {
            Section("Notifications") {
                NotificationTimePickerView(hour: $notificationHour, minute: $notificationMinute)
                    .onChange(of: notificationHour) { _, _ in
                        viewModel.requestAndSchedule(hour: notificationHour, minute: notificationMinute)
                    }
                    .onChange(of: notificationMinute) { _, _ in
                        viewModel.requestAndSchedule(hour: notificationHour, minute: notificationMinute)
                    }

                Text(statusText)
                    .foregroundStyle(Color.tenxTextSecondary)

                if viewModel.authorizationStatus == .denied {
                    Button("Open Settings") {
                        NotificationScheduler.shared.openSystemSettings()
                    }
                }

                #if DEBUG
                Button("Send Test Notification") {
                    viewModel.scheduleTest()
                }
                #endif
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
