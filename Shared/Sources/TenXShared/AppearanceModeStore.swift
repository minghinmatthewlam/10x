import SwiftUI

public enum AppearanceModeSetting: String, CaseIterable {
    case system
    case light
    case dark
}

public enum AppearanceModeStore {
    public static func storedMode(userDefaults: UserDefaults? = UserDefaults(suiteName: SharedConstants.appGroupID)) -> AppearanceModeSetting? {
        guard let raw = userDefaults?.string(forKey: SharedConstants.appearanceModeKey) else {
            return nil
        }
        return AppearanceModeSetting(rawValue: raw)
    }

    public static func updateSharedMode(_ rawValue: String,
                                        userDefaults: UserDefaults? = UserDefaults(suiteName: SharedConstants.appGroupID)) {
        userDefaults?.set(rawValue, forKey: SharedConstants.appearanceModeKey)
    }

    public static func effectiveColorScheme(system: ColorScheme, storedMode: AppearanceModeSetting?) -> ColorScheme {
        guard let storedMode else { return system }
        switch storedMode {
        case .system:
            return system
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    public static func palette(systemScheme: ColorScheme,
                               userDefaults: UserDefaults? = UserDefaults(suiteName: SharedConstants.appGroupID)) -> ThemePalette {
        let stored = storedMode(userDefaults: userDefaults)
        let scheme = effectiveColorScheme(system: systemScheme, storedMode: stored)
        return Theme.midnight.palette(for: scheme)
    }
}
