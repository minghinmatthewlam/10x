import Foundation

struct NotificationPreferences: Equatable {
    let morningHour: Int
    let morningMinute: Int
    let middayEnabled: Bool
    let eveningEnabled: Bool

    static func current(userDefaults: UserDefaults = .standard) -> NotificationPreferences {
        let hour = userDefaults.object(forKey: UserDefaultsKeys.notificationHour) as? Int
            ?? AppConstants.defaultNotificationHour
        let minute = userDefaults.object(forKey: UserDefaultsKeys.notificationMinute) as? Int
            ?? AppConstants.defaultNotificationMinute
        let middayEnabled = userDefaults.object(forKey: UserDefaultsKeys.middayReminderEnabled) as? Bool
            ?? AppConstants.defaultMiddayReminderEnabled
        let eveningEnabled = userDefaults.object(forKey: UserDefaultsKeys.eveningReminderEnabled) as? Bool
            ?? AppConstants.defaultEveningReminderEnabled
        return NotificationPreferences(morningHour: hour,
                                       morningMinute: minute,
                                       middayEnabled: middayEnabled,
                                       eveningEnabled: eveningEnabled)
    }
}
